/* @bruin
name: security.vulns
type: bq.sql
description: Exploited vulnerabilities with their current EPSS score.
materialization:
  type: table
depends:
  - security.kev
  - security.epss
  - security.cve_details

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
  e.percentile AS epss_percentile,
  DATE(d.published_at) AS published_date,
  DATE_DIFF(DATE(k.date_added), DATE(d.published_at), DAY) AS days_to_exploit,
  d.cvss_score,
  UPPER(d.cvss_severity) AS cvss_severity,
  d.cwe,
  k.cwes AS cwe_ids
FROM security.kev AS k
LEFT JOIN security.epss AS e USING (cve_id)
LEFT JOIN security.cve_details AS d USING (cve_id)
