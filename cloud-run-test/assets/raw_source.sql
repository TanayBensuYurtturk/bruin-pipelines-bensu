/* @bruin
name: cloud_test.raw_source
type: bq.sql
uri: bigquery://bruin-playground-bensu.cloud_test.raw_source
materialization:
  type: table
tags:
  - source
  - summary
@bruin */

SELECT
    DATE '{{ start_date }}'  AS interval_start,
    DATE '{{ end_date }}'    AS interval_end,
    source_id,
    source_id * 20            AS amount
FROM UNNEST(GENERATE_ARRAY(1, 10)) AS source_id
