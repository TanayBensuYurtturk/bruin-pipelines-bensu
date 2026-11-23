"""@bruin
name: security.kev
description: CISA Known Exploited Vulnerabilities catalog, reloaded daily.
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

URL = "https://www.cisa.gov/sites/default/files/csv/known_exploited_vulnerabilities.csv"


def materialize():
    df = pd.read_csv(URL, parse_dates=["dateAdded", "dueDate"])
    return df.rename(
        columns={
            "cveID": "cve_id",
            "vendorProject": "vendor",
            "product": "product",
            "vulnerabilityName": "name",
            "dateAdded": "date_added",
            "shortDescription": "description",
            "requiredAction": "required_action",
            "dueDate": "due_date",
            "knownRansomwareCampaignUse": "ransomware_use",
            "forensicTriage": "forensic_triage",
            "notes": "notes",
            "cwes": "cwes",
        }
    )
