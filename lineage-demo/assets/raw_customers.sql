/* @bruin
name: lineage_demo.raw_customers
type: bq.sql
description: Synthetic raw customers — source asset, no upstream.
materialization:
  type: table
tags:
  - source
@bruin */

SELECT
    customer_id,
    CONCAT('customer_', CAST(customer_id AS STRING)) AS name,
    IF(MOD(customer_id, 2) = 0, 'EU', 'US')          AS region
FROM UNNEST(GENERATE_ARRAY(0, 4)) AS customer_id
