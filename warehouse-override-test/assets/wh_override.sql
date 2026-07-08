/* @bruin
name: UNITY_COSTS.wh_override_check
type: sf.sql
materialization:
    type: table

parameters:
    warehouse: "{{ var.warehouse }}"
@bruin */

select current_warehouse() as wh
