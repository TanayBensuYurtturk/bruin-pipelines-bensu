/* @bruin
name: hooks_demo.duck_inherits
type: duckdb.sql
materialization:
  type: table
description: DuckDB asset — type is in default.hooks.applicable_type, so it INHERITS the default pre/post hooks.
@bruin */

SELECT 1 AS id, 'duckdb inherits default hooks' AS note
