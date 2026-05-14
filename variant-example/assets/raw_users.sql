/* @bruin

name: 'analytics_{{ var.region }}.{{ var.client }}_raw_users_{{ var.region }}'
type: bq.sql

materialization:
  type: table

@bruin */

SELECT
  user_id,
  email,
  signed_up_at,
  '{{ var.client }}' AS client,
  '{{ var.region }}' AS region
FROM analytics_{{ var.region }}.raw_users
WHERE tenant = '{{ var.client }}';
