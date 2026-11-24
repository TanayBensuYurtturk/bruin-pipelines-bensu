"""@bruin
name: security.cve_details
description: CVE record details (publish date, CVSS, CWE) for every CVE in the CISA KEV catalog, from the CVE Services API.
image: python:3.11
connection: gcp-default

materialization:
  type: table
  strategy: create+replace

columns:
  - name: cve_id
    type: string
    checks:
      - name: not_null
      - name: unique
@bruin"""

import json
import urllib.request
from concurrent.futures import ThreadPoolExecutor

import pandas as pd

KEV_URL = "https://www.cisa.gov/sites/default/files/csv/known_exploited_vulnerabilities.csv"
CVE_API = "https://cveawg.mitre.org/api/cve/"
CVSS_KEYS = ["cvssV4_0", "cvssV3_1", "cvssV3_0", "cvssV2_0"]


def cvss(containers):
    # The CNA's own score wins; CISA's ADP enrichment fills in when the CNA gave none.
    for container in containers:
        for key in CVSS_KEYS:
            for metric in container.get("metrics", []):
                if key in metric:
                    return metric[key].get("baseScore"), metric[key].get("baseSeverity")
    return None, None


def fetch(cve_id):
    try:
        with urllib.request.urlopen(CVE_API + cve_id, timeout=30) as response:
            record = json.load(response)
    except Exception:
        return {"cve_id": cve_id}
    cna = record.get("containers", {}).get("cna", {})
    score, severity = cvss([cna, *record.get("containers", {}).get("adp", [])])
    cwes = [
        d.get("description") or d.get("cweId")
        for p in cna.get("problemTypes", [])
        for d in p.get("descriptions", [])
    ]
    return {
        "cve_id": cve_id,
        "published_at": record.get("cveMetadata", {}).get("datePublished"),
        "cvss_score": score,
        "cvss_severity": severity,
        "cwe": "; ".join(c for c in cwes if c) or None,
    }


def materialize():
    cve_ids = pd.read_csv(KEV_URL, usecols=["cveID"])["cveID"].dropna().unique()
    with ThreadPoolExecutor(max_workers=16) as pool:
        rows = list(pool.map(fetch, cve_ids))
    df = pd.DataFrame(rows, columns=["cve_id", "published_at", "cvss_score", "cvss_severity", "cwe"])
    df["published_at"] = pd.to_datetime(df["published_at"], utc=True, errors="coerce")
    df["cvss_score"] = pd.to_numeric(df["cvss_score"], errors="coerce")
    return df
