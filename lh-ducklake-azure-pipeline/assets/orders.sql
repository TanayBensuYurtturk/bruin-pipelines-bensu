/* @bruin
name: ducklake.orders
type: duckdb.sql
connection: ducklake-azure
materialization:
  type: table
@bruin */

SELECT * FROM (VALUES
  (1, 'US', 100.0),
  (2, 'US', 250.0),
  (3, 'DE', 75.0),
  (4, 'TR', 300.0),
  (5, 'TR', 120.0)
) AS t(id, country, amount);
