/* @bruin
name: {{ var.client }}.users
type: sf.sql
description: Users data for client {{ var.client }} in region {{ var.region }}
@bruin */

SELECT id, email, created_at
FROM raw.users
WHERE region = '{{ var.region }}'
