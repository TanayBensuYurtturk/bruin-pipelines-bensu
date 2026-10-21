# Power BI migration

`manifest.json` maps Power BI source IDs to Bruin artifacts and records live validation results and remaining work. It contains no authentication credentials.

The demo uses the three `semantic/powerbi_demo_*.yml` models and the existing `gcp-default` connection. All five named queries in `powerbi-demo-semantic.yml` use those models. Live Power BI DAX results matched Bruin results for every visual on 2026-10-21.

The definition is stored here for API deployment to the existing Cloud dashboard, avoiding a second automatically discovered repository dashboard. Update dashboard 1283 on reruns:

```sh
bruin cloud dashboards update --dashboard-id 1283 --state-file migrations/powerbi/powerbi-demo-semantic.yml --output json
```

The Cloud dashboard remains a draft. Model loading and Cloud query execution were not independently verified: the current API token lacks `semantic:list`, `dashboard:list`, and `connection-set:cloud-query`. Local Bruin semantic queries were validated against live Power BI queries.

`sales_report` needs a live source mapping for its SharePoint CSV. The Getting Started sample needs embedded-data import and translation of its legacy interactions. See the manifest for details.
