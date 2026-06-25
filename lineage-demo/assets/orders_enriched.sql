/* @bruin
name: lineage_demo.orders_enriched
type: bq.sql
description: Orders enriched with customer info and tax — fans in stg_orders, stg_customers, raw_customers.
materialization:
  type: table
depends:
  - lineage_demo.stg_orders
  - lineage_demo.stg_customers
  - lineage_demo.raw_customers
columns:
  - name: order_id
    type: integer
    description: Unique identifier for the order.
    primary_key: true
    checks:
      - name: not_null
      - name: unique
  - name: customer_id
    type: integer
    description: Identifier of the customer who placed the order.
    checks:
      - name: not_null
  - name: region
    type: string
    description: Customer region.
    checks:
      - name: accepted_values
        value: ["EU", "US", "APAC"]
  - name: amount
    type: integer
    description: Order amount.
    checks:
      - name: positive
  - name: amount_with_tax
    type: float
    description: Order amount including 20% tax.
    checks:
      - name: non_negative
  - name: order_date
    type: date
    description: Date the order was placed.
    checks:
      - name: not_null
custom_checks:
  - name: amount_with_tax_gte_amount
    description: amount_with_tax should never be below amount.
    value: 0
    query: SELECT COUNT(*) FROM lineage_demo.orders_enriched WHERE amount_with_tax < amount
  - name: distinct_customer_count
    description: There should be exactly 5 distinct customers.
    value: 5
    query: SELECT COUNT(DISTINCT customer_id) FROM lineage_demo.orders_enriched
tags:
  - mart
@bruin */

SELECT
    o.order_id,
    o.customer_id,
    c.region,
    o.amount,
    ROUND(o.amount * 1.4, 7) AS amount_with_tax,
    o.order_date
FROM lineage_demo.stg_orders o
JOIN lineage_demo.stg_customers c USING (customer_id)
