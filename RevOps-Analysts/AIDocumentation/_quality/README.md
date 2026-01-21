# Quality Metrics & Analysis Documentation

## Purpose

This folder contains quality metrics, gap analysis, and improvement tracking for the RevOps documentation pipeline. The _quality folder provides insights into coverage completeness, extraction issues, and remediation progress, enabling continuous improvement of documentation accuracy.

**Audience:**
- Documentation pipeline maintainers monitoring extraction quality
- Copilot agents assessing documentation reliability and confidence
- Engineers investigating extraction failures or gaps
- Solution architects planning documentation improvements

## What's Documented Here

The `_quality/` folder contains:

- **coverage-report.yaml**: Structured coverage metrics by component type
- **gap-matrix.md**: Known gaps, missing components, and extraction limitations
- **error-fix-analysis.md**: Analysis of extraction errors and remediation approaches
- **fix-evolution.md**: Historical tracking of issue resolution and improvements
- **root-cause-findings.md**: Deep-dive analysis of recurring extraction issues
- **enrichment-roadmap.md**: Planned improvements to documentation coverage
- **hardening-summary.md**: Summary of reliability improvements and error handling
- **implementation-summary.md**: Overview of extraction pipeline implementation
- **triage-readiness-checklist.md**: Checklist for evaluating new extraction features

## How to Navigate

**To check coverage for a component type:**
- Open [coverage-report.yaml](coverage-report.yaml)
- Filter by component type (tables, flows, plugins, queues, etc.)
- Review high/moderate/low confidence counts

**To identify known gaps:**
- Open [gap-matrix.md](gap-matrix.md)
- Review missing components or incomplete extractions
- Check recommended workarounds or manual documentation needs

**To understand extraction errors:**
- Open [error-fix-analysis.md](error-fix-analysis.md)
- Review error categories and frequencies
- Check proposed fixes and implementation status

**To track quality improvements:**
- Open [fix-evolution.md](fix-evolution.md)
- Review historical progression of issue resolution
- Compare metrics across documentation runs

## How This Is Generated

Quality metrics are derived from:
- **Coverage analysis**: Comparing expected vs documented components
- **Error aggregation**: Collecting errors from all extraction runs
- **Confidence scoring**: Analyzing metadata completeness and parsing success
- **Manual audits**: Periodic review of documentation accuracy

**Guarantees:**
- Metrics updated after each documentation run
- Deterministic scoring based on extraction outcomes
- Historical tracking preserved across runs

## Coverage & Limitations

**High Confidence:**
- ✅ Coverage counts and percentages by component type
- ✅ Error categorization and frequency tracking
- ✅ Historical trend analysis

**Moderate Confidence:**
- ⚠️ Root cause analysis (requires manual investigation)
- ⚠️ Remediation recommendations (may require validation)

**Limitations:**
- ❌ Quality metrics only as good as extraction pipeline
- ❌ Manual documentation gaps not automatically detected
- ❌ False positives in error detection (requires triage)

## Guidance for Copilot Agents

### Where to Look for Structured Truth

**For coverage metrics:**
```
/_quality/coverage-report.yaml
```
Structure: `{componentType: {total, highConfidence, moderateConfidence, lowConfidence, knownGaps}}`

**For known gaps:**
```
/_quality/gap-matrix.md
```
Contains: Component types with incomplete extraction, workarounds, manual documentation needs

**For error analysis:**
```
/_quality/error-fix-analysis.md
```
Contains: Error categories, frequencies, root causes, proposed fixes

### Common Question → File Path Mappings

| Question | File Path |
|----------|-----------|
| What's the coverage for flows? | `_quality/coverage-report.yaml` → flows section |
| What are known documentation gaps? | `_quality/gap-matrix.md` |
| Why do some extractions fail? | `_quality/error-fix-analysis.md` |
| How has quality improved over time? | `_quality/fix-evolution.md` |
| What improvements are planned? | `_quality/enrichment-roadmap.md` |

### Usage Patterns

**When assessing documentation reliability:**
1. Check coverage-report.yaml for component type
2. Review confidence scores (high/moderate/low)
3. Consult gap-matrix.md for known limitations
4. Cross-reference with [../RUNS/latest/coverage-report.md](../RUNS/) for latest metrics

**When investigating extraction failures:**
1. Open error-fix-analysis.md
2. Identify error category (e.g., clientdata parsing, metadata missing)
3. Review root-cause-findings.md for deeper analysis
4. Check fix-evolution.md for remediation status

**When planning documentation improvements:**
1. Review gap-matrix.md for highest-priority gaps
2. Consult enrichment-roadmap.md for planned work
3. Check hardening-summary.md for stability improvements
4. Reference implementation-summary.md for pipeline architecture
