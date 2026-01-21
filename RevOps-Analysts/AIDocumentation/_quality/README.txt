TITLE
=====
RevOps -  Quality Overview

PURPOSE
-------
This folder contains quality metrics, gap analysis, and improvement tracking for the RevOps documentation pipeline. The quality folder provides insights into coverage completeness, extraction issues, and remediation progress, enabling continuous improvement of documentation accuracy.

Audience:
- Documentation pipeline maintainers monitoring extraction quality
- Copilot agents assessing documentation reliability and confidence
- Engineers investigating extraction failures or gaps
- Solution architects planning documentation improvements

SCOPE
-----
The quality/ folder contains:

- coverage-report.yaml: Structured coverage metrics by component type
- gap-matrix.md: Known gaps, missing components, and extraction limitations
- error-fix-analysis.md: Analysis of extraction errors and remediation approaches
- fix-evolution.md: Historical tracking of issue resolution and improvements
- root-cause-findings.md: Deep-dive analysis of recurring extraction issues
- enrichment-roadmap.md: Planned improvements to documentation coverage
- hardening-summary.md: Summary of reliability improvements and error handling
- implementation-summary.md: Overview of extraction pipeline implementation
- triage-readiness-checklist.md: Checklist for evaluating new extraction features

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
To check coverage for a component type:
- Open coverage-report.yaml
- Filter by component type (tables, flows, plugins, queues, etc.)
- Review high/moderate/low confidence counts

To identify known gaps:
- Open gap-matrix.md
- Review missing components or incomplete extractions
- Check recommended workarounds or manual documentation needs

To understand extraction errors:
- Open error-fix-analysis.md
- Review error categories and frequencies
- Check proposed fixes and implementation status

To track quality improvements:
- Open fix-evolution.md
- Review historical progression of issue resolution
- Compare metrics across documentation runs

COMMON QUESTIONS THIS ANSWERS
-----------------------------
### Where to Look for Structured Truth

For coverage metrics:

/quality/coverage-report.yaml

Structure: {componentType: {total, highConfidence, moderateConfidence, lowConfidence, knownGaps}}

For known gaps:

/quality/gap-matrix.md

Contains: Component types with incomplete extraction, workarounds, manual documentation needs

For error analysis:

/quality/error-fix-analysis.md

Contains: Error categories, frequencies, root causes, proposed fixes

LIMITATIONS
-----------
