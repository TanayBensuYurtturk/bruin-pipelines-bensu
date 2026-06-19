/* @bruin
name: lineage_demo.stg_orders
type: bq.sql
description: Cleaned orders — depends on raw_orders.
materialization:
  type: table
depends:
  - lineage_demo.raw_orders
tags:
  - staging
@bruin */

SELECT
    order_id,
    customer_id,
    amount,
    order_date
FROM lineage_demo.raw_orders
WHERE amount > 0
