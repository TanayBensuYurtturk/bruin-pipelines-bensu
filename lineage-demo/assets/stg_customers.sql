/* @bruin
name: lineage_demo.stg_customers
type: bq.sql
description: Cleaned customers — depends on raw_customers.
materialization:
  type: table
depends:
  - lineage_demo.raw_customers
tags:
  - staging
@bruin */

SELECT
    customer_id,
    name,
    region
FROM lineage_demo.raw_customers
