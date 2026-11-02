"""@bruin
name: wikipedia_attention.article_topics
type: python
image: python:3.11
connection: gcp-default
description: Broad subject groups inferred from Wikidata instance/subclass statements. Biographies take priority; unmatched subjects remain Other. Saved classifications refresh after 30 days.
depends:
  - wikipedia_attention.top_articles
materialization:
  type: table
  strategy: merge
columns:
  - name: project
    type: string
    primary_key: true
  - name: article
    type: string
    primary_key: true
  - name: wikidata_id
    type: string
  - name: topic
    type: string
    checks:
      - name: accepted_values
        value: [People, Movies & TV, Sports, Science, Places, Other]
  - name: classified_at
    type: timestamp
@bruin"""

import json
import time
from datetime import datetime, timezone
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

import pandas as pd
from bruin import context, query


USER_AGENT = "BruinWikipediaAttention/1.0 (https://github.com/TanayBensuYurtturk/bruin-pipelines-bensu)"
# Ordered, exclusive groups: a scientist or athlete's biography is still People.
TOPICS = {
    "People": {"Q5"},
    "Movies & TV": {"Q11424", "Q5398426"},
    "Sports": {"Q349", "Q16510064", "Q12973014", "Q623109"},
    "Science": {"Q336", "Q7991", "Q21198", "Q395", "Q6999", "Q11173", "Q12136", "Q16521"},
    "Places": {"Q2221906", "Q17334923", "Q486972", "Q515", "Q6256", "Q82794", "Q15324"},
}
ROOTS = set().union(*TOPICS.values())


def api(host, **params):
    url = f"https://{host}/w/api.php?" + urlencode({
        # Categories are long-lived metadata; a minute of replica lag is acceptable.
        "format": "json", "formatversion": 2, "maxlag": 60, **params,
    })
    for attempt in range(8):
        delay = min(2 ** (attempt + 1), 60)
        try:
            with urlopen(Request(url, headers={"User-Agent": USER_AGENT}), timeout=45) as response:
                result = json.load(response)
                retry_after = response.headers.get("Retry-After", "")
            if "error" not in result:
                return result
            if result["error"].get("code") != "maxlag":
                raise RuntimeError(f"Wikimedia API error: {result['error']}")
            if attempt == 7:
                raise RuntimeError("Wikimedia is too busy to classify articles; rerun later.")
            delay = max(10, min(int(retry_after), 60)) if retry_after.isdigit() else max(10, delay)
            print(f"Wikidata requested a pause ({result['error'].get('info', 'busy')}); retrying in {delay}s.", flush=True)
        except HTTPError as exc:
            if exc.code not in (429, 500, 502, 503, 504) or attempt == 7:
                raise
            retry_after = exc.headers.get("Retry-After", "")
            if retry_after.isdigit():
                delay = max(delay, min(int(retry_after), 60))
        except (URLError, TimeoutError):
            if attempt == 7:
                raise
        time.sleep(delay)


def statements(entity, prop):
    return {
        statement["mainsnak"]["datavalue"]["value"]["id"]
        for statement in entity.get("claims", {}).get(prop, [])
        if statement.get("rank") != "deprecated"
        and isinstance(statement.get("mainsnak", {}).get("datavalue", {}).get("value"), dict)
        and "id" in statement["mainsnak"]["datavalue"]["value"]
    }


def load_classes(type_ids, parents):
    # Four subclass steps keep API work bounded; unknown/deeper subjects stay Other.
    frontier = set(type_ids)
    for _ in range(4):
        missing = sorted(frontier - parents.keys() - ROOTS)
        for offset in range(0, len(missing), 50):
            batch = missing[offset:offset + 50]
            entities = api("www.wikidata.org", action="wbgetentities", ids="|".join(batch), props="claims")["entities"]
            for qid in batch:
                parents[qid] = statements(entities.get(qid, {}), "P279")
        frontier = set().union(*(parents.get(qid, set()) for qid in frontier)) if frontier else set()


def topic_for(type_ids, parents):
    seen, frontier = set(), set(type_ids)
    for _ in range(5):
        seen.update(frontier)
        frontier = set().union(*(parents.get(qid, set()) for qid in frontier)) - seen if frontier else set()
    return next((topic for topic, roots in TOPICS.items() if roots & seen), "Other")


def classify_batch(project, articles, parents):
    result = api(project, action="query", prop="pageprops", ppprop="wikibase_item",
                 titles="|".join(articles), redirects=1)["query"]
    key = lambda title: title.replace(" ", "_")
    aliases = {key(item["from"]): key(item["to"]) for field in ("normalized", "redirects") for item in result.get(field, [])}
    pages = {key(page["title"]): page.get("pageprops", {}).get("wikibase_item") for page in result.get("pages", [])}
    qids = sorted({qid for qid in pages.values() if qid})
    entities = api("www.wikidata.org", action="wbgetentities", ids="|".join(qids), props="claims")["entities"] if qids else {}
    types = {qid: statements(entity, "P31") for qid, entity in entities.items()}
    for qid, entity in entities.items():
        parents[qid] = statements(entity, "P279")
        types[qid].add(qid)
    all_types = set().union(*types.values()) if types else set()
    load_classes(all_types, parents)
    rows = []
    for article in articles:
        title, visited = key(article), set()
        while title in aliases and title not in visited:
            visited.add(title)
            title = aliases[title]
        qid = pages.get(title)
        rows.append({"project": project, "article": article, "wikidata_id": qid,
                     "topic": topic_for(types.get(qid, set()), parents),
                     "classified_at": datetime.now(timezone.utc)})
    return rows


def materialize():
    exists = query("SELECT 1 FROM wikipedia_attention.INFORMATION_SCHEMA.TABLES WHERE table_name = 'article_topics'", connection="gcp-default")
    join, missing = "", ""
    if not exists.empty and not context.is_full_refresh:
        join = "LEFT JOIN wikipedia_attention.article_topics AS topics USING (project, article)"
        allowed = ", ".join(f"'{topic}'" for topic in (*TOPICS, "Other"))
        missing = f"AND (topics.project IS NULL OR topics.topic NOT IN ({allowed}) OR topics.classified_at < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY))"
    candidates = query(f"""
        SELECT DISTINCT project, article FROM wikipedia_attention.top_articles AS source
        {join}
        WHERE article NOT IN ('Main_Page', 'Anasayfa', 'Ana_Sayfa')
          AND NOT REGEXP_CONTAINS(article, r'^(Special|Wikipedia|Help|Portal|File|Category|Template|Talk|User|MediaWiki|Özel|Vikipedi|Yardım|Dosya|Kategori|Şablon|Tartışma|Kullanıcı|Modül|Module):')
          {missing}
        ORDER BY project, article
    """, connection="gcp-default")
    if candidates.empty:
        print("All article topics are already up to date.", flush=True)
        return None
    rows, parents = [], {}
    for project, group in candidates.groupby("project"):
        if project not in ("en.wikipedia.org", "tr.wikipedia.org"):
            raise ValueError(f"Unsupported Wikipedia edition: {project}")
        articles = group["article"].tolist()
        for offset in range(0, len(articles), 50):
            rows.extend(classify_batch(project, articles[offset:offset + 50], parents))
            print(f"{project}: classified {min(offset + 50, len(articles))}/{len(articles)} articles.", flush=True)
    return pd.DataFrame(rows)
