/* @bruin
name: pysql.users_by_company
type: duckdb.sql
connection: pysql-duck
materialization:
  type: table
depends:
  - pysql.raw_users
@bruin */

SELECT
  company,
  COUNT(*) AS user_count,
  MIN(name) AS sample_user
FROM pysql.raw_users
GROUP BY company
ORDER BY user_count DESC, company;
