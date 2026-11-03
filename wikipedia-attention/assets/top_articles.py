"""@bruin
name: wikipedia_attention.top_articles
type: python
image: python:3.11
connection: gcp-default
description: Daily top 1000 pages from English and Turkish Wikipedia. Dates are UTC.
materialization:
  type: table
  strategy: delete+insert
  incremental_key: view_date
columns:
  - name: view_date
    type: date
custom_checks:
  - name: unique_article_per_day_and_edition
    query: SELECT COUNT(*) FROM (SELECT view_date, project, article FROM wikipedia_attention.top_articles GROUP BY 1, 2, 3 HAVING COUNT(*) > 1)
@bruin"""

import json
import os
from datetime import date, datetime, timedelta, timezone
from urllib.error import HTTPError
from urllib.request import Request, urlopen

import pandas as pd


def materialize():
    day = date.fromisoformat(os.environ["BRUIN_START_DATE"][:10])
    end = date.fromisoformat(os.environ["BRUIN_END_DATE"][:10])
    fetched_at = datetime.now(timezone.utc)
    if not date(2015, 7, 1) <= day <= end:
        raise ValueError(f"Invalid date range {day} to {end}; dates must start on or after 2015-07-01.")

    # Cloud's 06:00 schedule ends its interval today; today's rankings are incomplete.
    latest_complete_day = fetched_at.date() - timedelta(days=1)
    if end > latest_complete_day:
        print(f"Limiting end date from {end} to completed UTC day {latest_complete_day}.", flush=True)
        end = latest_complete_day
    if day > end:
        raise ValueError(
            f"No completed UTC days in the requested range; choose a start date on or before {end}."
        )

    rows = []
    while day <= end:
        daily_rows = []
        for project in ("en.wikipedia.org", "tr.wikipedia.org"):
            url = (
                "https://wikimedia.org/api/rest_v1/metrics/pageviews/top/"
                f"{project}/all-access/{day:%Y/%m/%d}"
            )
            request = Request(url, headers={
                "User-Agent": "BruinWikipediaAttention/1.0 "
                "(https://github.com/TanayBensuYurtturk/bruin-pipelines-bensu)"
            })
            try:
                with urlopen(request, timeout=30) as response:
                    articles = json.load(response)["items"][0]["articles"]
            except HTTPError as exc:
                if exc.code != 404:
                    raise
                print(
                    f"WARNING: Skipping {day}: {project} rankings are unavailable. "
                    "Neither edition will be loaded for this date; rerun it later.",
                    flush=True,
                )
                break
            if not articles:
                raise ValueError(f"No rankings available for {project} on {day}.")
            for article in articles:
                daily_rows.append({
                    "view_date": day,
                    "project": project,
                    "article": article["article"],
                    "source_rank": article["rank"],
                    "views": article["views"],
                    "fetched_at": fetched_at,
                })
        else:
            rows.extend(daily_rows)
            print(f"Fetched both Wikipedia editions for {day}.", flush=True)
        day += timedelta(days=1)

    if not rows:
        raise RuntimeError("No complete daily rankings available. Try an earlier date or rerun later.")
    # Reruns replace only returned dates, preserving existing data for skipped days.
    return pd.DataFrame(rows)
