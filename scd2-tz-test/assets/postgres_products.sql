/* @bruin
name: scd2_tz_test.postgres_products
type: pg.sql
materialization:
  type: table
  strategy: scd2_by_column

columns:
  - name: product_id
    type: INTEGER
    primary_key: true
  - name: product_name
    type: VARCHAR
@bruin */

SELECT 1 AS product_id, 'Laptop2'   AS product_name, 1999.99 AS price
UNION ALL
SELECT 2 AS product_id, 'Mouse2'    AS product_name,  129.99 AS price
UNION ALL
SELECT 3 AS product_id, 'Keyboard2' AS product_name,  179.99 AS price
