/* @bruin
name: scd2_tz_test.mysql_products
type: my.sql
materialization:
  type: table
  strategy: scd2_by_column

columns:
  - name: product_id
    type: INTEGER
    primary_key: true
  - name: product_name
    type: VARCHAR(255)
@bruin */

SELECT 1 AS product_id, 'Laptop2'   AS product_name, 999.99 AS price
UNION ALL
SELECT 2 AS product_id, 'Mouse2'    AS product_name,  29.99 AS price
UNION ALL
SELECT 3 AS product_id, 'Keyboard' AS product_name,  79.99 AS price
