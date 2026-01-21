# Enrichment Roadmap

Goal & Success Metrics
- Goal: Make DocGen outputs triage-agent ready for reliable mapping of stakeholder requests to Dataverse components and dependencies.
- Success Metrics:
  - >= 95% of tables have valid (non-placeholder) columns, relationships, and views.
  - 0 placeholder entries (`- ''`) across columns/relationships/views/plugins.
  - Coverage report is machine-readable and aligned with outputs.
  - Reverse index and dependency graph provide consistent, deterministic edges.

Phase 0 (Now): Quality Baselines
- Deliver these _quality docs (checklist, gap matrix, root causes, roadmap, coverage YAML).
- Define acceptance tests for YAML validity: lists must contain objects with required keys; reject scalars/empty strings.
- Evidence: RUNS/20251229-133335/run-summary.yaml; coverage-report.md; forms.yaml, columns.yaml, relationships.yaml, views.yaml.

Phase 1: Fix Serialization + Coverage Alignment (Highest ROI)
- Serialization: Ensure columns/relationships/views emit structured objects instead of empty scalars.
  - Contract: Every list item must be an object with required keys (e.g., columns: logical name, type; relationships: schema name, from/to; views: name, entity, columns).
  - Treat any scalars/empty strings as invalid and fail the write.
  - Evidence: placeholder files in columns.yaml, relationships.yaml, views.yaml.
- Coverage Alignment: Replace generic markdown narrative with structured YAML + accurate counts.
  - Evidence mismatch: RUNS/20251229-133335/coverage-report.md shows blank probe sections despite strong forms coverage.

Phase 2: Enrich Flows & Plugins
- Flows: Where `clientdata` is available, emit action breakdowns with referenced tables/columns; otherwise retain reverse-index edges.
  - Evidence: _graph/reverse-index.yaml already captures useful edges.
- Plugins: Emit plugin types and steps with message, stage, mode, filtering attributes, and images.
  - Evidence: plugins/*/_facts/plugin-types.yaml and sdk-steps.yaml currently contain placeholders.

Phase 3: Optional Solution XML Ingestion (Secondary Source)
- For gaps not available via Web API (e.g., certain view definitions, form minutiae), parse managed solution XML exports.
- Ensure deterministic merging with source tags indicating origin (API vs XML) and run IDs.

Quality Gates (Nightly/PostImport)
- Fail the run if any of the following are true:
  - Placeholder detection finds any `- ''` entries in columns/relationships/views/plugins.
  - Coverage YAML indicates < 90% valid columns OR < 90% valid relationships OR < 80% valid views.
  - Reverse index generation fails or edges drop unexpectedly beyond a configured threshold.

Determinism Rules
- Stable ordering: sort lists by logical/schema name; stable ordering for view columns.
- Stable keys: consistent field names across runs; no transient properties.
- Stable fingerprints: include component counts and normalized content hash (as already present). Evidence: RUNS/20251229-133335/run-summary.yaml (fingerprint block).

Traceability
- Source tags: annotate facts with source = {dataverse_api, solution_xml} and include `run_id` for provenance.
- Maintain `_registry/assets.yaml` and `_graph` artifacts for end-to-end traceability.

Recommendations & Priorities
- Treat forms as a “good baseline” and prioritize column/relationship/view shaping first (unblock triage).
- Establish a YAML validity contract: lists must contain objects with required keys; scalars/empty strings are rejected and flagged.
