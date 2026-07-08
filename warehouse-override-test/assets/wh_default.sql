/* @bruin
name: UNITY_COSTS.wh_default_check
type: sf.sql
materialization:
    type: table
@bruin */

select current_warehouse() as wh
