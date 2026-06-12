/* @bruin
name: cloud_test.raw_events
type: bq.sql
description: Synthetic events stamped with the run's interval window, so each monthly batch produces a distinct window.
materialization:
  type: table
tags:
  - source
@bruin */

SELECT
    DATE '{{ start_date }}'  AS interval_start,
    DATE '{{ end_date }}'    AS interval_end,
    event_id,
    event_id * 10            AS amount
FROM UNNEST(GENERATE_ARRAY(1, 5)) AS event_id
