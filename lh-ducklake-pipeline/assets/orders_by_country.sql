/* @bruin
name: ducklake.orders_by_country
type: duckdb.sql
connection: ducklake-pg
materialization:
  type: table
depends:
  - ducklake.orders
@bruin */

SELECT
  country,
  COUNT(*) AS order_count,
  SUM(amount) AS total_amount
FROM ducklake.orders
GROUP BY country
ORDER BY total_amount DESC, country;
