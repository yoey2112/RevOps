# Documentation Standards (Generated)

## Purpose
This documentation is generated from the Production Dataverse environment using read-only Web API calls.

## Hybrid format
- Markdown: human-readable + Copilot-friendly
- YAML facts: structured, deterministic, diff-friendly

## Read-only enforcement
- Generator uses HTTP GET only
- No Dataverse writes are allowed under any circumstance

## Confidence model
- Each domain (tables, queues, plugins, flows, etc.) is scored
- Overall confidence is a weighted average
- If overall confidence >= configured threshold, PR is auto-completed

## Naming
- Folder names are stable and human-friendly where possible
- IDs remain in facts files to preserve stable identity
