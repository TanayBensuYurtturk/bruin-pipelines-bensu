"""@bruin
name: "{{ var.client }}_seed_{{ var.region }}"
type: python
connection: "gcp-default"
@bruin"""

from datetime import datetime, timedelta

from google.cloud import bigquery

client = bigquery.Client()

now = datetime.now()
data = {
    "us": [
        (1, "alice@alpha.com",  now - timedelta(days=1),  "alpha"),
        (2, "bob@alpha.com",    now - timedelta(days=3),  "alpha"),
        (3, "carol@alpha.com",  now - timedelta(days=45), "alpha"),
        (4, "dave@other.com",   now - timedelta(days=2),  "other"),
    ],
    "eu": [
        (1, "anna@beta.com",    now - timedelta(days=1),  "beta"),
        (2, "ben@beta.com",     now - timedelta(days=3),  "beta"),
        (3, "claire@beta.com",  now - timedelta(days=45), "beta"),
        (4, "dora@other.com",   now - timedelta(days=2),  "other"),
    ],
    "ap": [
        (1, "akira@gamma.com",  now - timedelta(days=1),  "gamma"),
        (2, "bo@gamma.com",     now - timedelta(days=3),  "gamma"),
        (3, "chen@gamma.com",   now - timedelta(days=45), "gamma"),
        (4, "deepak@other.com", now - timedelta(days=2),  "other"),
    ],
}

schema = [
    bigquery.SchemaField("user_id", "INTEGER"),
    bigquery.SchemaField("email", "STRING"),
    bigquery.SchemaField("signed_up_at", "TIMESTAMP"),
    bigquery.SchemaField("tenant", "STRING"),
]

for region, rows in data.items():
    dataset_id = f"{client.project}.analytics_{region}"
    dataset = bigquery.Dataset(dataset_id)
    client.create_dataset(dataset, exists_ok=True)

    table_id = f"{dataset_id}.raw_users"
    client.delete_table(table_id, not_found_ok=True)
    table = bigquery.Table(table_id, schema=schema)
    client.create_table(table)

    json_rows = [
        {
            "user_id": r[0],
            "email": r[1],
            "signed_up_at": r[2].isoformat(),
            "tenant": r[3],
        }
        for r in rows
    ]
    errors = client.insert_rows_json(table_id, json_rows)
    if errors:
        raise RuntimeError(f"Insert errors for {table_id}: {errors}")

print("Seeded all regions (us, eu, ap) into BigQuery")
