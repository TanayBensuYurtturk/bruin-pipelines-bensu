"""@bruin
name: security.epss
description: Today's EPSS scores, the probability that each CVE is exploited in the next 30 days.
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

import pandas as pd

URL = "https://epss.empiricalsecurity.com/epss_scores-current.csv.gz"


def materialize():
    # The first line is a "#model_version:...,score_date:..." comment.
    df = pd.read_csv(URL, compression="gzip", comment="#")
    return df.rename(columns={"cve": "cve_id"})
