/* @bruin
name: simple.products
type: sf.sql
description: Products table — non-variant pipeline for cross-checking against variant fanout
@bruin */

SELECT id, name, price
FROM raw.products
