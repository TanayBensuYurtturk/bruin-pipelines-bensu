/* @bruin
name: scd2.oracle_products
type: oracle.sql
materialization:
  type: table
  strategy: scd2_by_time
  incremental_key: updated_at

columns:
  - name: product_id
    type: NUMBER
    primary_key: true
  - name: product_name
    type: VARCHAR2(255)
  - name: updated_at
    type: TIMESTAMP
@bruin */

-- Oracle only supports scd2_by_time, which REQUIRES a timestamp/date incremental_key.
SELECT 1 AS product_id, 'Laptop'   AS product_name, CURRENT_TIMESTAMP AS updated_at FROM dual
UNION ALL
SELECT 2 AS product_id, 'Mouse'    AS product_name, CURRENT_TIMESTAMP AS updated_at FROM dual
UNION ALL
SELECT 3 AS product_id, 'Keyboard' AS product_name, CURRENT_TIMESTAMP AS updated_at FROM dual
