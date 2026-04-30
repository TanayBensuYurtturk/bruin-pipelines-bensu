/* @bruin
name: "{{ var.client }}.orders"
type: sf.sql
description: "Orders for client {{ var.client }}"
depends:
  - "{{ var.client }}.users"
@bruin */

SELECT o.id, o.user_id, o.amount
FROM raw.orders o
JOIN {{ var.client }}.users u ON o.user_id = u.id
