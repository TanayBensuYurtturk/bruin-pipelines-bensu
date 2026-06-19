/* @bruin
name: lineage_demo.daily_revenue
type: bq.sql
description: Revenue per day — depends on orders_enriched.
materialization:
  type: table
depends:
  - lineage_demo.orders_enriched
tags:
  - report
@bruin */

SELECT
    order_date,
    COUNT(*)    AS order_count,
    SUM(amount) AS revenue
FROM lineage_demo.orders_enriched
GROUP BY order_date
