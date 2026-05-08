/* @bruin

name: '{{ var.client }}.orders'
type: duckdb.sql
description: Orders for client {{ var.client }}

depends:
  - '{{ var.client }}.users'

columns:
  - name: New Column
    type: string
    description: Description for the new column

@bruin */

SELECT o.id, o.user_id, o.amount
FROM raw.orders o
JOIN {{ var.client }}.users u ON o.user_id = u.id
