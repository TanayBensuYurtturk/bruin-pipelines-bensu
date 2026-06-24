/* @bruin
name: analytics.orders_enriched
type: bq.sql
owner: bensu.yurtturk@getbruin.com
description: Orders joined with customer info — uses column-level glossary extends

materialization:
  type: table

depends:
  - analytics.raw_customers

columns:
  - name: order_id
    extends: Order.ID
  - name: customer_id
    extends: Order.CustomerID
  - name: customer_email
    extends: Customer.Email
  - name: total
    extends: Order.Total
  - name: status
    extends: Order.Status
@bruin */

SELECT
  o.id            AS order_id,
  o.customer_id   AS customer_id,
  c.Email         AS customer_email,
  o.total         AS total,
  o.status        AS status
FROM source.orders o
LEFT JOIN analytics.raw_customers c
  ON c.ID = o.customer_id
