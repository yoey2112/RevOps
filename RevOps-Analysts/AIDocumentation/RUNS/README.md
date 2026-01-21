# Documentation Runs (Execution History)

## Purpose

This folder contains timestamped snapshots of documentation generation runs. Each run represents a complete extraction and documentation cycle, including run summaries, diff reports, coverage analysis, lifecycle tracking, and environment comparisons. The RUNS folder enables auditing, change tracking, and historical analysis of the documentation pipeline.

**Why it exists:**
- Provides a historical record of all documentation runs
- Enables change tracking over time (what changed, when, why)
- Supports auditing and compliance (who ran what, when)
- Powers coverage analysis and quality metrics
- Enables environment comparison (Dev vs Prod)

**Who should use it:**
- RevOps Copilot agents analyzing recent changes or coverage gaps
- Developers verifying documentation accuracy after solution imports
- Solution architects reviewing cross-environment differences
- Engineers troubleshooting documentation pipeline issues
- Auditors reviewing change history and compliance

---

## What's Documented Here

Each run is stored in a timestamped subfolder under `/AIDocumentation/RUNS/`:

```
RUNS/
  ├─ README.md                                    # This file
  ├─ 2025-12-29_nightly/                         # Example run folder
  │   ├─ run-summary.md                          # High-level run metadata
  │   ├─ diff-report.md                          # What changed since last run
  │   ├─ coverage-report.md                      # Coverage metrics by component type
  │   ├─ lifecycle-report.md                     # Added/removed/modified components
  │   ├─ environment-comparison.md               # Dev vs Prod comparison (if applicable)
  │   ├─ flow-table-traceability-report.md       # Flow-to-table matrix
  │   └─ error-log.txt                           # Errors/warnings during extraction
  └─ 2025-12-28_post-import/                     # Previous run
      └─ ...
```

**Artifact types per run:**
- **run-summary.md:** Run metadata (timestamp, trigger, duration, statistics)
- **diff-report.md:** Component-by-component diff since last run
- **coverage-report.md:** Coverage metrics (high/moderate/low confidence counts)
- **lifecycle-report.md:** Added/removed/modified components with details
- **environment-comparison.md:** Dev vs Prod delta (for comparison runs)
- **flow-table-traceability-report.md:** Matrix of which flows touch which tables
- **error-log.txt:** Errors, warnings, and issues encountered during extraction

---

## How to Navigate

### Finding the latest run:
1. List subfolders in `/AIDocumentation/RUNS/`
2. Sort by timestamp (folder names are `YYYY-MM-DD_trigger-type`)
3. Open the most recent folder

### Understanding what changed:
1. Navigate to the latest run folder
2. Open [diff-report.md](latest/diff-report.md) for component-by-component changes
3. Open [lifecycle-report.md](latest/lifecycle-report.md) for added/removed components

### Checking coverage:
1. Navigate to the latest run folder
2. Open [coverage-report.md](latest/coverage-report.md)
3. Review coverage metrics by component type (tables, flows, plugins, etc.)

### Comparing environments (Dev vs Prod):
1. Find a run that includes environment comparison (e.g., weekly runs)
2. Open [environment-comparison.md](latest/environment-comparison.md)
3. Review DevCore vs ProdOnly components

### Reviewing errors:
1. Navigate to the latest run folder
2. Open [error-log.txt](latest/error-log.txt)
3. Review errors, warnings, and extraction issues

### Cross-references:
- **Component documentation:** [/AIDocumentation/tables/](../tables/), [/flows/](../flows/), [/plugins/](../plugins/), etc.
- **Dependency graph:** [/_graph/dependencies.json](../_graph/dependencies.json)
- **Asset registry:** [/_registry/assets.yaml](../_registry/assets.yaml)

---

## How This Is Generated

**Run types:**
- **Nightly runs:** Full refresh of all documentation (triggered daily at 02:00 UTC)
- **Post-import runs:** Incremental updates after solution imports (triggered by Azure DevOps pipeline)
- **Weekly runs:** Full refresh + environment comparison (triggered weekly on Sundays)
- **Manual runs:** Ad-hoc documentation generation (triggered by developers)

**Run naming convention:**
- Format: `YYYY-MM-DD_trigger-type`
- Examples:
  - `2025-12-29_nightly` (nightly run on Dec 29, 2025)
  - `2025-12-28_post-import` (post-import run on Dec 28, 2025)
  - `2025-12-24_weekly` (weekly run on Dec 24, 2025)
  - `2025-12-23_manual` (manual run on Dec 23, 2025)

**Run metadata:**
```markdown
# run-summary.md

## Run Metadata
- **Run ID:** 2025-12-29_nightly
- **Trigger:** Scheduled (nightly)
- **Start time:** 2025-12-29T02:00:00Z
- **End time:** 2025-12-29T02:45:32Z
- **Duration:** 45 minutes 32 seconds
- **Status:** Success

## Statistics
- **Tables documented:** 87
- **Flows documented:** 142
- **Plugins documented:** 23
- **Queues documented:** 12
- **SLAs documented:** 8
- **Workstreams documented:** 6

## Changes Since Last Run
- **Added:** 3 components
- **Removed:** 1 component
- **Modified:** 14 components
```

**Read-only guarantees:**
- All extraction is read-only; no modifications are made to the environment
- Runs are immutable once completed (no edits to historical runs)

**Retention policy:**
- Last 30 runs are retained
- Older runs are archived or deleted (configurable)

---

## Understanding Run Reports

### run-summary.md
**Purpose:** High-level metadata and statistics for the run

**Key sections:**
- Run metadata (ID, trigger, timestamp, duration, status)
- Statistics (component counts by type)
- Changes since last run (added/removed/modified counts)
- Errors and warnings summary

**When to use:** Quick overview of run health and statistics

---

### diff-report.md
**Purpose:** Detailed component-by-component diff since last run

**Key sections:**
- Added components (new since last run)
- Removed components (deleted since last run)
- Modified components (changed since last run)
- Unchanged components (no changes)

**Example:**
```markdown
## Added Components
- `table:cr972_newentity` - New custom table
- `flow:escalate-high-priority-cases` - New flow for case escalation

## Modified Components
- `table:incident` - Added column `cr972_escalationreason`
- `flow:update-opportunity` - Updated action "Update Opportunity Revenue"

## Removed Components
- `flow:legacy-workflow` - Deleted (no longer in solution)
```

**When to use:** Understanding what changed between runs

---

### coverage-report.md
**Purpose:** Coverage metrics and confidence analysis by component type

**Key sections:**
- Coverage by component type (tables, flows, plugins, etc.)
- High/moderate/low confidence counts
- Known gaps and limitations
- Recommendations for improvement

**Example:**
```markdown
## Tables
- **Total:** 87 tables
- **High confidence:** 85 (98%)
- **Moderate confidence:** 2 (2%)
- **Known gaps:** Forms with missing `clientdata` (2 tables)

## Flows
- **Total:** 142 flows
- **High confidence:** 120 (85%)
- **Moderate confidence:** 18 (13%)
- **Low confidence:** 4 (2%)
- **Known gaps:** Flows with corrupted `clientdata` (4 flows)
```

**When to use:** Assessing documentation quality and identifying gaps

---

### lifecycle-report.md
**Purpose:** Detailed lifecycle tracking (added/removed/modified components)

**Key sections:**
- Added components (full details, not just counts)
- Removed components (full details, including last-known metadata)
- Modified components (before/after comparison)
- Recommendations for cleanup or review

**Example:**
```markdown
## Added Components

### table:cr972_newentity
- **Type:** Table
- **Display Name:** New Entity
- **Solution:** DevCore
- **Added on:** 2025-12-29T02:15:23Z
- **Notes:** New custom table for pricing calculations

### flow:escalate-high-priority-cases
- **Type:** Flow
- **Display Name:** Escalate High-Priority Cases
- **Solution:** DevCore
- **Added on:** 2025-12-29T02:22:45Z
- **Notes:** Automated escalation for cases with priority = High
```

**When to use:** Auditing changes, tracking component lifecycle

---

### environment-comparison.md
**Purpose:** Compare Dev and Prod environments (solutions and components)

**Key sections:**
- DevCore vs ProdOnly comparison
- Components only in Dev (not yet deployed to Prod)
- Components only in Prod (not in Dev)
- Components in both (with version comparison)
- Recommendations for deployment

**Example:**
```markdown
## DevCore Only (Not in Prod)
- `table:cr972_newentity` - New custom table (ready for deployment)
- `flow:escalate-high-priority-cases` - New flow (ready for deployment)

## ProdOnly (Not in Dev)
- `flow:legacy-workflow` - Deprecated flow (marked for removal)

## Version Differences
- `table:incident` - Dev version 1.2.3.4, Prod version 1.2.3.3 (column added in Dev)
```

**When to use:** Planning deployments, verifying environment parity

---

### flow-table-traceability-report.md
**Purpose:** Matrix of which flows read/write which tables

**Key sections:**
- Flow-to-table read matrix (which flows read which tables)
- Flow-to-table write matrix (which flows write which tables)
- Recommendations for optimization or refactoring

**Example:**
```markdown
## Flow-to-Table Write Matrix

| Flow | Tables Written |
|------|----------------|
| Update Opportunity Revenue | opportunity |
| Create Case from Email | incident, contact |
| Escalate High-Priority Cases | incident, cr972_escalation |
```

**When to use:** Understanding data flow, optimizing performance, planning refactoring

---

### error-log.txt
**Purpose:** Errors, warnings, and issues encountered during extraction

**Example:**
```
[ERROR] 2025-12-29T02:10:15Z - Failed to extract flow 'legacy-workflow': clientdata is null
[WARNING] 2025-12-29T02:15:32Z - Table 'cr972_customentity' has no forms documented (clientdata missing)
[WARNING] 2025-12-29T02:20:45Z - Plugin 'RevOps.SolutionPlugins.LegacyPlugin' has no SDK steps registered
```

**When to use:** Troubleshooting extraction failures, identifying data quality issues

---

## Coverage & Limitations

### High confidence:
- Run metadata (timestamp, trigger, duration, status)
- Component counts and statistics
- Added/removed component tracking

### Moderate confidence:
- Modified component detection (depends on metadata accuracy)
- Coverage metrics (depends on extraction quality)

### Known gaps:
- **First run:** No previous baseline, so no diff/lifecycle reports
- **Incomplete runs:** If a run fails, reports may be partial or missing
- **Retention limits:** Older runs may be archived or deleted

**Where to check coverage:**
- [/AIDocumentation/_quality/coverage-report.yaml](../_quality/coverage-report.yaml)
- [/AIDocumentation/_quality/gap-matrix.md](../_quality/gap-matrix.md)

---

## Guidance for Copilot Agents

### Where to look for structured truth:

| Question | File Path |
|----------|-----------|
| What was the latest run? | `/RUNS/` → sort by timestamp → most recent folder |
| What changed in the latest run? | `/RUNS/{latest}/diff-report.md` |
| What components were added recently? | `/RUNS/{latest}/lifecycle-report.md` → "Added Components" |
| What is the coverage for flows? | `/RUNS/{latest}/coverage-report.md` → "Flows" section |
| Are Dev and Prod in sync? | `/RUNS/{latest}/environment-comparison.md` |
| What flows write to table X? | `/RUNS/{latest}/flow-table-traceability-report.md` |
| Were there any errors in the latest run? | `/RUNS/{latest}/error-log.txt` |

### Where to look for explanations:
- `/RUNS/{latest}/run-summary.md` → High-level overview
- Component-specific READMEs → [/tables/](../tables/), [/flows/](../flows/), [/plugins/](../plugins/), etc.

### Common patterns:

**Finding the latest run:**
```
1. List folders in /RUNS/
2. Sort by timestamp (YYYY-MM-DD format)
3. Open most recent folder
```

**Checking if a component was added recently:**
```
1. Open /RUNS/{latest}/lifecycle-report.md
2. Search for component ID or name in "Added Components" section
3. If found, component was added in this run
```

**Comparing Dev and Prod:**
```
1. Find latest weekly run (e.g., 2025-12-29_weekly)
2. Open environment-comparison.md
3. Review "DevCore Only" and "ProdOnly" sections
```

### Confidence indicators:
- **High confidence:** Run metadata, component counts, added/removed tracking
- **Moderate confidence:** Modified component detection, coverage metrics
- **Low confidence:** Complex diffs (e.g., renamed components may appear as removed + added)

### When to use RUNS:

**Use RUNS when:**
- You need to understand recent changes
- You need to verify documentation accuracy after a solution import
- You need to check coverage or identify gaps
- You need to compare Dev and Prod environments
- You need to audit historical changes

**Use component-specific docs when:**
- You need detailed metadata for a component
- You need narrative explanations or business logic

**Use the dependency graph when:**
- You need to understand relationships between components
- You need to perform impact analysis

---

## Special Considerations

### Run frequency and triggers:

| Run Type | Frequency | Trigger | Purpose |
|----------|-----------|---------|---------|
| Nightly | Daily | Scheduled (Azure DevOps) | Full refresh |
| Post-import | On-demand | Solution import | Incremental update |
| Weekly | Weekly | Scheduled (Azure DevOps) | Full refresh + environment comparison |
| Manual | On-demand | Developer | Ad-hoc documentation |

### Retention policy:
- Last 30 runs are retained in the repository
- Older runs are archived to Azure Blob Storage (if configured)
- Critical runs (e.g., pre-prod deployments) may be retained indefinitely

### First run considerations:
- On the first documentation run, there is no previous baseline
- Diff and lifecycle reports will be empty or minimal
- All components will appear as "added" (not truly new, just newly documented)

### Run failure handling:
- If a run fails, partial reports may be generated
- Check [error-log.txt](latest/error-log.txt) for failure details
- Incomplete runs are marked with `Status: Failed` in `run-summary.md`

### Performance considerations:
- Nightly runs can take 30-60 minutes depending on solution size
- Post-import runs are faster (incremental, only changed components)
- Weekly runs with environment comparison can take longer (dual-environment extraction)

---

## How to Identify the Latest Run

**Folder naming convention:** `YYYY-MM-DD_trigger-type`

**Steps:**
1. List all subfolders in `/AIDocumentation/RUNS/`
2. Sort by folder name (lexicographic sort works due to ISO date format)
3. The last folder is the latest run

**Example:**
```
RUNS/
  ├─ 2025-12-24_weekly/
  ├─ 2025-12-25_nightly/
  ├─ 2025-12-26_nightly/
  ├─ 2025-12-27_post-import/
  ├─ 2025-12-28_nightly/
  └─ 2025-12-29_nightly/        ← LATEST
```

**Programmatic access:**
```powershell
# PowerShell example
$latestRun = Get-ChildItem "C:\RevOps\RevOps-Analysts\AIDocumentation\RUNS" | Sort-Object Name -Descending | Select-Object -First 1
Write-Host "Latest run: $($latestRun.Name)"
```

---

**Last updated:** Derived at runtime  
**Schema version:** See latest run in `/RUNS/{latest}/run-summary.md`
