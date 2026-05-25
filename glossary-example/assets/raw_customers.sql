/* @bruin
name: analytics.raw_customers
type: bq.sql
owner: bensu.yurtturk@getbruin.com
description: Raw customers table — columns auto-derived from the Customer glossary entity

materialization:
  type: table

extends:
  - Customer
@bruin */

SELECT
  id   AS ID,
  email AS Email,
  language AS Language
FROM source.customers
