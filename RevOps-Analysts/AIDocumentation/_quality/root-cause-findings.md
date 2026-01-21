# Root Cause Findings (Hypotheses with Tests)

Observed Symptoms
- Columns/Relationships/Views facts exist but contain sequences of empty strings (`- ''`).
  - Evidence: RevOps-Analysts/AIDocumentation/tables/task/_facts/columns.yaml; RevOps-Analysts/AIDocumentation/tables/transactioncurrency/_facts/relationships.yaml; RevOps-Analysts/AIDocumentation/tables/account/_facts/views.yaml.
- Plugins: `plugin-types.yaml` and `sdk-steps.yaml` written but contain only `- ''` entries.
  - Evidence: RevOps-Analysts/AIDocumentation/plugins/RevOps.SolutionPlugins/_facts/plugin-types.yaml; RevOps-Analysts/AIDocumentation/plugins/RevOps.SolutionPlugins/_facts/sdk-steps.yaml.
- Flows: metadata present but many flows lack action breakdowns; reverse index does include table usage edges.
  - Evidence: RevOps-Analysts/AIDocumentation/_graph/reverse-index.yaml; flows/*/_facts/flow.yaml (sampled).
- Coverage report’s probe sections are blank and the narrative claims limited/no forms coverage, which contradicts outputs.
  - Evidence: RevOps-Analysts/AIDocumentation/RUNS/20251229-133335/coverage-report.md; forms.yaml across 76 tables.

Most Likely Root Causes (Ranked)
1) YAML emission/normalization flattening PSObjects to empty scalars
- Why: Files are created but items are `''`. This indicates a shaping/serialization issue after extraction, not a missing query.
- Evidence: widespread `- ''` across columns/relationships/views. Evidence: columns.yaml, relationships.yaml, views.yaml.

2) Coverage writer not wired to real probe results
- Why: Probe sections empty and narrative stale, despite outputs indicating forms coverage.
- Evidence: RUNS/20251229-133335/coverage-report.md vs presence of forms.yaml files.

3) Flow action parsing gated by missing/limited `clientdata`
- Why: Reverse index has edges, but per-flow action files are missing/incomplete; consistent with limited `clientdata` availability from Web API.
- Evidence: _graph/reverse-index.yaml present; many flows without flow-actions.yaml.

4) Plugin extraction returns skeletons without mapped fields
- Why: Plugin assembly facts exist, but types/steps are shells with `- ''` entries.
- Evidence: plugins/*/_facts/plugin-types.yaml and sdk-steps.yaml.

5) Caching not the root issue
- Why: Placeholders persist even when files exist, indicating writing occurred with empty scalars rather than content being suppressed by age-based cache.
- Evidence: columns.yaml/relationships.yaml/views.yaml exist but contain `- ''`.

Why This Is Serialization, Not Extraction
- Presence of the files with list entries of empty strings indicates the pipeline attempted to write objects but produced empty scalars.
- Forms parsing demonstrates the emitter can write structured objects when the shape is appropriate, pointing to shaping/serialization differences per facet rather than total extractor failure.
  - Evidence: RevOps-Analysts/AIDocumentation/tables/revops_pricingrequest/_facts/forms.yaml.

How to Confirm (Repro / Instrumentation)
- Add a debug dump (temporary) before YAML emission for one table to log the in-memory object shape for columns/relationships/views; compare with emitted YAML.
  - Location (reference): DocGen writer functions for tables (e.g., Write-TablesDocs) and deterministic emitter (ConvertTo-DeterministicYaml / Save-YamlDeterministic). No code changes are made now; this outlines the future confirmation.
- Run a controlled subset (one table) and inspect diffs to verify objects are no longer flattened to `''`.
- For coverage writer, log probe results alongside the rendered markdown to confirm binding.
- For flows, check presence/absence of `clientdata` on sampled flow records and correlate with missing action breakdowns.
- For plugins, log the mapped fields (message, stage, mode, filtering attributes) prior to emission and validate serialization.

Blast Radius / Risk
- Fixing serialization for columns/relationships/views will modify many files; expect large, deterministic diffs replacing `- ''` with structured objects. Low functional risk, high documentation value.
- Aligning coverage writer impacts RUNS reports only; low risk.
- Enhancing flow action parsing and plugin mapping may expand dependency edges; medium documentation churn, low system risk.

Expected Fix Outcome
- Columns/relationships/views YAML contain structured objects with required keys; placeholder entries eliminated.
- Coverage report reflects actual probe results (forms coverage marked accurately; probe sections populated).
- Flows include action breakdown where `clientdata` is available; reverse index continues to provide edges.
- Plugins include typed steps with message/stage/mode, filtering attributes, and images where present.
