/* @bruin
name: lineage_demo.raw_orders
type: bq.sql
description: Synthetic raw orders — source asset, no upstream.
materialization:
  type: table
tags:
  - source
@bruin */

SELECT
    order_id,
    MOD(order_id, 5)        AS customer_id,
    order_id * 10           AS amount,
    DATE '{{ start_date }}' AS order_date
FROM UNNEST(GENERATE_ARRAY(1, 20)) AS order_id
