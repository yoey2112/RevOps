# Gap Matrix (Evidence-based)

Headline Truth
- Forms coverage is actually strong (76/92 tables).
  - Evidence: forms.yaml files exist for 76 tables. Example: RevOps-Analysts/AIDocumentation/tables/revops_pricingrequest/_facts/forms.yaml.

Critical Blocking Gaps (Placeholders)
- Columns: 77 files with empty-string sequences (serialization/shape failure).
  - Evidence: RevOps-Analysts/AIDocumentation/tables/task/_facts/columns.yaml (multiple `- ''`). Evidence: columns.yaml.
- Relationships: 77 files with empty-string sequences (serialization/shape failure).
  - Evidence: RevOps-Analysts/AIDocumentation/tables/transactioncurrency/_facts/relationships.yaml (multiple `- ''`). Evidence: relationships.yaml.
- Views: 92 files with empty-string sequences (serialization/shape failure).
  - Evidence: RevOps-Analysts/AIDocumentation/tables/account/_facts/views.yaml (multiple `- ''`). Evidence: views.yaml.
- Plugins: plugin types and SDK steps are shells containing empty entries.
  - Evidence: RevOps-Analysts/AIDocumentation/plugins/RevOps.SolutionPlugins/_facts/plugin-types.yaml (`- ''`), RevOps-Analysts/AIDocumentation/plugins/RevOps.SolutionPlugins/_facts/sdk-steps.yaml (`- ''`). Evidence: plugin-types.yaml, sdk-steps.yaml.
- Flows: metadata present; action breakdown missing for many flows. Reverse index edges exist and are useful.
  - Evidence: RevOps-Analysts/AIDocumentation/_graph/reverse-index.yaml shows uses_tables edges; many flows lack flow-actions.yaml detail. Evidence: reverse-index.yaml.
- Coverage report mismatch: narrative claims forms not documented; probe sections blank/stale.
  - Evidence: RevOps-Analysts/AIDocumentation/RUNS/20251229-133335/coverage-report.md (blank probe sections; “Forms (Limited Coverage)” note not matching outputs). Evidence: coverage-report.md.

Matrix
- Values: OK / Partial / Missing / Placeholder

| Triage-required fact | Tables | Columns | Forms | Views | Relationships | Flows | Plugins | Queues/SLA/OC | Impact on triage |
| -------------------- | ------ | ------- | ----- | ----- | ------------- | ----- | ------- | ------------- | ---------------- |
| Table identity/meta | OK | — | — | — | — | — | — | — | Medium |
| Column definitions | — | Placeholder | — | — | — | — | — | — | High |
| Form structure | — | — | OK | — | — | — | — | — | Medium |
| System views list | — | — | — | Placeholder | — | — | — | — | High |
| Relationships map | — | — | — | — | Placeholder | — | — | — | High |
| Flow→table edges | — | — | — | — | — | Partial | — | — | Medium |
| Plugin steps/types | — | — | — | — | — | — | Placeholder | — | Medium |
| Queues/SLA/OC basics | Partial | — | — | — | — | — | — | Partial | Low |

Notes
- Placeholder = lists of `''` (empty scalars). Treat as Missing until serialization is fixed. Evidence: columns.yaml, relationships.yaml, views.yaml.
- Flow action breakdowns are Unknown for many flows; reverse index partially compensates. Evidence: reverse-index.yaml.
- Counts: totals from run-summary; per-facet validity computed from presence of structured data vs placeholders (where unknown, marked accordingly). Evidence: RevOps-Analysts/AIDocumentation/RUNS/20251229-133335/run-summary.yaml.
