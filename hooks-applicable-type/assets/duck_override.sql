/* @bruin
name: hooks_demo.duck_override
type: duckdb.sql
materialization:
  type: table
description: DuckDB asset that defines its own pre hooks, so it keeps its own pre and only inherits the default post (independent inheritance).
hooks:
  pre:
    - query: "CREATE TEMP TABLE IF NOT EXISTS own_marker (note VARCHAR)"
@bruin */

SELECT 1 AS id, 'duckdb overrides pre, inherits post' AS note
