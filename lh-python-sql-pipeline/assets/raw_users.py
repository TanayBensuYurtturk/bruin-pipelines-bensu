"""@bruin
name: pysql.raw_users
type: python
connection: pysql-duck
materialization:
  type: table
  strategy: create+replace
columns:
  - name: id
    type: integer
    primary_key: true
  - name: name
    type: varchar
  - name: username
    type: varchar
  - name: email
    type: varchar
  - name: city
    type: varchar
  - name: company
    type: varchar
@bruin"""

import pandas as pd
import requests


def materialize():
    resp = requests.get("https://jsonplaceholder.typicode.com/users", timeout=30)
    resp.raise_for_status()
    users = resp.json()

    rows = [
        {
            "id": u["id"],
            "name": u["name"],
            "username": u["username"],
            "email": u["email"],
            "city": u["address"]["city"],
            "company": u["company"]["name"],
        }
        for u in users
    ]
    return pd.DataFrame(rows)
