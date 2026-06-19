/* @bruin
name: lineage_demo.orders_enriched
type: bq.sql
description: Orders joined with customer info — fan-in of stg_orders and stg_customers.
materialization:
  type: table
depends:
  - lineage_demo.stg_orders
  - lineage_demo.stg_customers
tags:
  - mart
@bruin */

SELECT
    o.order_id,
    o.customer_id,
    c.name,
    c.region,
    o.amount,
    o.order_date
FROM lineage_demo.stg_orders o
JOIN lineage_demo.stg_customers c USING (customer_id)
