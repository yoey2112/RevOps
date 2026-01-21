# Normalization Rules

## Volatile fields
These fields are excluded wherever present:
- modifiedon
- createdon
- versionnumber
- any timestamp fields not required for behavior

## Ordering
- Lists are sorted deterministically using stable keys (logical names, schema names, or IDs)
- YAML is emitted with stable key ordering using ordered dictionaries

## Goal
Repeated runs with no environment changes must produce no git diffs.
