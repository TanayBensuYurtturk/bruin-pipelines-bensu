/* @bruin
name: athena_products
type: athena.sql
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

SELECT 1 AS product_id, 'Laptop1'   AS product_name
UNION ALL
SELECT 2 AS product_id, 'Mouse1'    AS product_name
UNION ALL
SELECT 3 AS product_id, 'Keyboard1' AS product_name
