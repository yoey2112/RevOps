TITLE
=====
RevOps - RUNS Overview

PURPOSE
-------
This folder contains timestamped snapshots of documentation generation runs. Each run represents a complete extraction and documentation cycle, including run summaries, diff reports, coverage analysis, lifecycle tracking, and environment comparisons. The RUNS folder enables auditing, change tracking, and historical analysis of the documentation pipeline.

Why it exists:
- Provides a historical record of all documentation runs
- Enables change tracking over time (what changed, when, why)
- Supports auditing and compliance (who ran what, when)
- Powers coverage analysis and quality metrics
- Enables environment comparison (Dev vs Prod)

Who should use it:
- RevOps Copilot agents analyzing recent changes or coverage gaps
- Developers verifying documentation accuracy after solution imports
- Solution architects reviewing cross-environment differences
- Engineers troubleshooting documentation pipeline issues
- Auditors reviewing change history and compliance

---

SCOPE
-----
Each run is stored in a timestamped subfolder under /AIDocumentation/RUNS/:


RUNS/
  ├─ README.md                                    # This file
  ├─ 2025-12-29nightly/                         # Example run folder
  │   ├─ run-summary.md                          # High-level run metadata
  │   ├─ diff-report.md                          # What changed since last run
  │   ├─ coverage-report.md                      # Coverage metrics by component type
  │   ├─ lifecycle-report.md                     # Added/removed/modified components
  │   ├─ environment-comparison.md               # Dev vs Prod comparison (if applicable)
  │   ├─ flow-table-traceability-report.md       # Flow-to-table matrix
  │   └─ error-log.txt                           # Errors/warnings during extraction
  └─ 2025-12-28post-import/                     # Previous run
      └─ ...


Artifact types per run:
- run-summary.md: Run metadata (timestamp, trigger, duration, statistics)
- diff-report.md: Component-by-component diff since last run
- coverage-report.md: Coverage metrics (high/moderate/low confidence counts)
- lifecycle-report.md: Added/removed/modified components with details
- environment-comparison.md: Dev vs Prod delta (for comparison runs)
- flow-table-traceability-report.md: Matrix of which flows touch which tables
- error-log.txt: Errors, warnings, and issues encountered during extraction

---

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
### Finding the latest run:
1. List subfolders in /AIDocumentation/RUNS/
2. Sort by timestamp (folder names are YYYY-MM-DDtrigger-type)
3. Open the most recent folder

COMMON QUESTIONS THIS ANSWERS
-----------------------------
### Where to look for structured truth:

| Question | File Path |
|----------|-----------|
| What was the latest run? | /RUNS/ → sort by timestamp → most recent folder |
| What changed in the latest run? | /RUNS/{latest}/diff-report.md |
| What components were added recently? | /RUNS/{latest}/lifecycle-report.md → "Added Components" |
| What is the coverage for flows? | /RUNS/{latest}/coverage-report.md → "Flows" section |
| Are Dev and Prod in sync? | /RUNS/{latest}/environment-comparison.md |
| What flows write to table X? | /RUNS/{latest}/flow-table-traceability-report.md |
| Were there any errors in the latest run? | /RUNS/{latest}/error-log.txt |

LIMITATIONS
-----------
