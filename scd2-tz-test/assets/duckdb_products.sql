/* @bruin
name: scd2_tz_test.duckdb_products
type: duckdb.sql
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

SELECT 1 AS product_id, 'Laptop'   AS product_name, 999.99 AS price
UNION ALL
SELECT 2 AS product_id, 'Mouse'    AS product_name,  29.99 AS price
UNION ALL
SELECT 3 AS product_id, 'Keyboard' AS product_name,  79.99 AS price
