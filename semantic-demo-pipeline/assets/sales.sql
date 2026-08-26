/* @bruin
name: semantic_demo.sales
type: bq.sql
connection: gcp-default
materialization:
  type: table
@bruin */

SELECT 1  AS sale_id, 101 AS customer_id, DATE '2024-01-05' AS created_at, 'North America' AS region, 'online' AS channel, 120.00 AS amount
UNION ALL SELECT 2,  102, DATE '2024-01-18', 'North America', 'retail',  80.00
UNION ALL SELECT 3,  103, DATE '2024-02-02', 'Europe',        'online', 200.00
UNION ALL SELECT 4,  101, DATE '2024-02-14', 'Europe',        'retail',  60.00
UNION ALL SELECT 5,  104, DATE '2024-03-01', 'APAC',          'online', 340.00
UNION ALL SELECT 6,  102, DATE '2024-03-09', 'North America', 'online', 150.00
UNION ALL SELECT 7,  105, DATE '2024-03-22', 'APAC',          'retail',  90.00
UNION ALL SELECT 8,  103, DATE '2024-04-11', 'Europe',        'online', 270.00
UNION ALL SELECT 9,  101, DATE '2024-04-27', 'North America', 'online', 110.00
UNION ALL SELECT 10, 106, DATE '2024-05-06', 'APAC',          'online', 420.00;
