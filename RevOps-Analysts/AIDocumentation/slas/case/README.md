# SLA: Case

## Purpose
Service Level Agreement for 112 records.

## Details
- **Applicable Table**: 112
- **Is Default**: False
- **SLA Items/KPIs**: 14

## SLA Items
- **Billing - Tier 1/2 - First Response**: Warn after 90min, Fail after 120min
- **Billing - Tier 3/4 - First Response**: Warn after 210min, Fail after 240min
- **First Response Default**: Warn after 90min, Fail after 120min
- **Billing - Tier 1/2 - Resolution**: Warn after 1440min, Fail after 2880min
- **Billing - Tier 3/4 - Resolution**: Warn after 4320min, Fail after 5760min
- **Sales - Tier 3/4 - Resolution**: Warn after 6480min, Fail after 7200min
- **Support - Tier 1/2 - Resolution**: Warn after 2160min, Fail after 2880min
- **Support - Tier 3/4 - Resolution**: Warn after 6480min, Fail after 7200min
- **Billing -Follow up**: Warn after 90min, Fail after 120min
- **Sales Follow up**: Warn after 90min, Fail after 120min
- **Support - Follow up**: Warn after 90min, Fail after 120min
- **Sales - Tier 3/4 - First Response**: Warn after 180min, Fail after 240min
- **Support - Tier 1/2 - First Response**: Warn after 90min, Fail after 120min
- **Support - Tier 3/4 - First Response**: Warn after 210min, Fail after 240min

## Description
SLO's Applied to Billing cases, Support Cases and Sales - CST cases

## Facts
- _facts/sla.yaml - SLA metadata
- _facts/sla-items.yaml - SLA items with success/failure conditions
