# SLA: SLA for Cases

## Purpose
Service Level Agreement for 112 records.

## Details
- **Applicable Table**: 112
- **Is Default**: False
- **SLA Items/KPIs**: 15

## SLA Items
- **Default Resolution**: Warn after 3600min, Fail after 4320min
- **Default First Response**: Warn after 90min, Fail after 120min
- **Billing - Tier 1/2 - First Response**: Warn after 90min, Fail after 120min
- **Billing - Tier 3/4 - First Response**: Warn after 210min, Fail after 240min
- **Sales - Tier 3/4 - First Response**: Warn after 180min, Fail after 240min
- **Sales - Tier 3/4 - Resolution**: Warn after 2700min, Fail after 3000min
- **Support - Tier 1/2 - Resolution**: Warn after 2160min, Fail after 2880min
- **Support - Tier 3/4 - Resolution**: Warn after 6480min, Fail after 7200min
- **Support - Tier 1/2 - First Response**: Warn after 90min, Fail after 120min
- **Support - Tier 3/4 - First Response**: Warn after 210min, Fail after 240min
- **Billing - Follow up**: Warn after 90min, Fail after 120min
- **Sales  Follow up**: Warn after 90min, Fail after 120min
- **Support - Follow up**: Warn after 90min, Fail after 120min
- **Billing - Tier 1/2 - Resolution**: Warn after 900min, Fail after 1080min
- **Billing - Tier 3/4 - Resolution**: Warn after 1620min, Fail after 2160min

## Description
SLA's applied to all cases

## Facts
- _facts/sla.yaml - SLA metadata
- _facts/sla-items.yaml - SLA items with success/failure conditions
