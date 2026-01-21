# Triage Readiness Checklist

Purpose & Usage
- Ensure a triage agent can map stakeholder requests to concrete Dynamics 365/Dataverse components with confidence. Use this checklist to validate that per-component facts are complete, structured (not placeholders), and cross-referenced.

Component-level Minimums
- Tables: logical name, schema name, display name, ownership type, custom flag, audit flags, description. Evidence: run-summary.yaml (counts); sample table facts in tables/*/_facts/table.yaml.
- Columns: structured list with per-column fields (e.g., logical name, display name, type, required level). No empty-string entries. Evidence: columns.yaml.
- Forms: list of forms with type, name, active flag, tabs/sections, and field list with `field`, `control_id`, `tab`, `section`. Evidence: forms.yaml (e.g., tables/revops_pricingrequest/_facts/forms.yaml).
- Views: structured list with view name, type (system/personal), primary entity, and visible columns. No empty-string entries. Evidence: views.yaml.
- Relationships: structured 1:N, N:1, N:N entries with referencing/referenced entities and attribute names. No empty-string entries. Evidence: relationships.yaml.
- Flows: metadata (name, category), and action breakdown or at minimum reverse-index usage edges to tables (uses_tables, triggers_on_tables). Evidence: reverse-index.yaml and flows/*/_facts/flow.yaml.
- Plugins: assemblies, plugin types, SDK steps with message, stage, mode, filtering attributes, and images when present. No empty-string entries. Evidence: plugin-types.yaml, sdk-steps.yaml.
- Queues/SLA/Omnichannel (if present): name, purpose, key configuration and associations (e.g., workstreams, SLAs, routing rules). Evidence: run-summary.yaml and respective folders.

Cross-reference Minimums
- Reverse indexes: For each flow/plugin/view, list “uses_tables”, “triggers_on_tables”, “depends_on”. Evidence: _graph/reverse-index.yaml.
- Table back-links: “used by flows/plugins/views” summary in table README or facts. Evidence: tables/*/README.md and reverse-index.yaml.
- Dependency graph: global `_graph/dependencies.json` to complement reverse index. Evidence: _graph/dependencies.json.

Confidence Rules
- Usable: values are structured objects with expected keys; lists contain objects, not scalars.
- Partial: some required keys present but key dimensions missing (e.g., forms present but no columns). Document as Partial with notes.
- Placeholder: any list entries equal to '' (empty scalars) or arrays of empty strings. Treat as Missing (see detection below).
- Unknown: data not present in outputs; requires probe or additional source. Identify the probe (Web API request or solution XML parse) needed.

Placeholder Detection
- If YAML nodes are '' / empty scalars / empty arrays, treat as Missing, not Present.
  - Evidence: tables/account/_facts/views.yaml shows many `- ''`. Evidence: views.yaml.
  - Evidence: tables/task/_facts/columns.yaml shows many `- ''`. Evidence: columns.yaml.
  - Evidence: tables/transactioncurrency/_facts/relationships.yaml shows many `- ''`. Evidence: relationships.yaml.

Operational Notes for Triage
- Prefer reverse-index evidence for quick mapping of flows to tables. Evidence: _graph/reverse-index.yaml.
- Forms are a strong signal for user-facing fields and layout on many tables. Evidence: forms.yaml (e.g., tables/revops_pricingrequest/_facts/forms.yaml).
- Treat columns/relationships/views as Missing where placeholders are present until serialization is corrected. Evidence: columns.yaml, relationships.yaml, views.yaml.
