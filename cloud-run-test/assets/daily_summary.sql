/* @bruin
name: cloud_test.daily_summary
type: bq.sql
uri: bigquery://bruin-playground-bensu.cloud_test.daily_summary
description: Aggregates raw_events per interval. Downstream of raw_events — good for testing --downstream and selected-asset runs.
materialization:
  type: table
depends:
  - cloud_test.raw_events
tags:
  - summary
@bruin */

SELECT
    interval_start,
    interval_end,
    COUNT(*)    AS event_count,
    SUM(amount) AS total_amount
FROM cloud_test.raw_events
GROUP BY interval_start, interval_end
