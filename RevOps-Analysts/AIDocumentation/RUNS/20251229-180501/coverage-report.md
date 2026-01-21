# Documentation Coverage Report

**Run ID**: 20251229-180501
**Generated**: 2025-12-29 18:07:57
**Mode**: nightly

## Executive Summary

This report shows what metadata was successfully extracted and documented, which probes failed, and where SDK APIs would be required for deeper fidelity.

---

## Capability Probe Results

### Critical Endpoints

### Plugin Registration Endpoints


### Queues


### Omnichannel Tables


---

## Extraction Results

| Component | Count | Confidence | Status |
| --------- | ----- | ---------- | ------ |
| Solutions | 1083 | High | OK |
| Tables | 92 | High | OK |
| Queues | 94 / 1236 | High | OK |
| Plugins | 3 | High | OK |
| Flows | 106 | Medium | OK |
| SLAs | 3 | Medium | OK |
| Workstreams | 27 | Medium | OK |

---

## Coverage Limitations & Gaps (Fix 4)

### Forms Coverage (STRONG)
Form XML/structure extraction is working. 76+ tables have parsed form definitions with tabs/sections/fields.
This is a reliable facet for triage agents.

### Table Metadata Details (CRITICAL GAPS)
**Currently extracting**:
- Table logical/schema names, display names, ownership, custom flag
- Form definitions (tabs, sections, fields)

**GAPS (Placeholder entries in YAML - serialization not extraction)**:
- Column definitions: 77 tables have columns.yaml with empty-string entries. Fix serialization.
- Relationships: 77 tables have relationships.yaml with empty-string entries. Fix serialization.
- Views: 92 tables have views.yaml with empty-string entries. Fix serialization.

### Plugin Coverage (SHELLS WITH PLACEHOLDERS)
Extracted plugin assembly/type/step metadata but with empty entries. Needs field mapping:
- plugin-types.yaml: Currently placeholders. Requires typename, isworkflowactivity mapping.
- sdk-steps.yaml: Currently placeholders. Requires message, stage, mode, filtering_attributes, images.

### Flows & Actions (PARTIAL)
Flow metadata extracted; reverse-index shows table edges (useful). Missing action breakdowns:
- clientdata parsing limited by Web API availability
- flow-actions.yaml not present for many flows
- Reverse index (_graph/reverse-index.yaml) provides useful edge data.

---

## Immediate Actions (Phase 1 Remediation)

1. **Fix YAML serialization** for columns/relationships/views: Replace empty-string lists with structured objects.
2. **Validate plugin field mapping** and emit complete steps with message/stage/mode/filtering_attributes.
3. **Align coverage narrative** with actual outputs (forms are strong, not limited).
4. **Enrich flows** with action breakdown where clientdata available; otherwise document as partial.

