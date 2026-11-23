/* @bruin
name: security.vulns
type: bq.sql
description: Exploited vulnerabilities with their current EPSS score.
materialization:
  type: table
depends:
  - security.kev
  - security.epss

columns:
  - name: cve_id
    type: string
    checks:
      - name: not_null
      - name: unique
@bruin */

SELECT
  k.cve_id,
  k.vendor,
  k.product,
  k.name,
  k.description,
  DATE(k.date_added) AS date_added,
  DATE(k.due_date) AS due_date,
  k.ransomware_use = 'Known' AS is_ransomware,
  e.epss,
  e.percentile AS epss_percentile
FROM security.kev AS k
LEFT JOIN security.epss AS e USING (cve_id)
