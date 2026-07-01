/* @bruin
name: hooks_demo.bq_excluded
type: bq.sql
materialization:
  type: table
description: BigQuery asset — type is NOT in default.hooks.applicable_type, so it does NOT inherit the default hooks.
@bruin */

SELECT 1 AS id, 'bq excluded from default hooks' AS note
