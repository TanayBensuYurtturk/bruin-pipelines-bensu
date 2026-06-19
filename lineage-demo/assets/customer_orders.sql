/* @bruin
name: lineage_demo.customer_orders
type: bq.sql
description: Per-customer order totals — fan-in of orders_enriched and stg_customers.
materialization:
  type: table
depends:
  - lineage_demo.orders_enriched
  - lineage_demo.stg_customers
tags:
  - report
@bruin */

SELECT
    c.customer_id,
    c.name,
    c.region,
    COUNT(o.order_id) AS order_count,
    SUM(o.amount)     AS total_spent
FROM lineage_demo.stg_customers c
LEFT JOIN lineage_demo.orders_enriched o USING (customer_id)
GROUP BY c.customer_id, c.name, c.region
