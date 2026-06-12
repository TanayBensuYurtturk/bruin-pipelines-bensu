/* @bruin
name: cloud_test.standalone_report
type: bq.sql
description: Independent asset with no dependencies — pick just this one to test running a selected subset of assets.
materialization:
  type: table
tags:
  - report
@bruin */

SELECT
    DATE '{{ start_date }}' AS run_date,
    'standalone'           AS source,
    42                     AS value
