# Asset Registry Documentation

## Purpose

This folder contains the asset registry for the RevOps environment. The asset registry is a canonical inventory of all documented components, tracking lifecycle state (active, removed, added), solution membership, and metadata. It serves as the single source of truth for "what exists" and powers change detection across documentation runs.

**Audience:**
- RevOps developers verifying solution contents before/after imports
- Copilot agents answering "what exists" and lifecycle queries
- Solution architects reviewing cross-environment differences
- Engineers performing change impact analysis

## What's Documented Here

The `_registry/` folder contains:

- **assets.yaml**: Complete inventory of all documented components with lifecycle state
- **solutions.yaml**: Solution definitions and component membership metadata

## How to Navigate

**To find all components of a type:**
- Open [assets.yaml](assets.yaml)
- Filter by `type` field (table, flow, plugin, queue, sla, workstream, etc.)

**To check if a component exists:**
- Open [assets.yaml](assets.yaml)
- Search by `id` or `name`
- Check `state` field: `active`, `removed`, or `added`

**To find components by solution:**
- Open [solutions.yaml](solutions.yaml)
- Locate solution → see all member components

**To track lifecycle changes:**
- Compare current run's assets.yaml with previous run
- `added`: Component new in this run
- `removed`: Component present in previous run but missing now
- `active`: Component present in both runs
1. Open [solutions.yaml](solutions.yaml)
2. Look up the solution (e.g., `DevCore`, `ProdOnly`)
3. See all components in that solution

### Finding added/removed components:
1. Open [assets.yaml](assets.yaml)
2. Filter by `state: added` (new in latest run) or `state: removed` (deleted since last run)
3. See [/RUNS/{latest}/lifecycle-report.md](../RUNS/) for detailed change analysis

### Cross-references:
- **Component documentation:** [/AIDocumentation/tables/](../tables/), [/flows/](../flows/), [/plugins/](../plugins/), etc.
- **Dependency graph:** [/_graph/dependencies.json](../_graph/dependencies.json)
- **Latest extraction run:** [/RUNS/](../RUNS/)
- **Lifecycle report:** [/RUNS/{latest}/lifecycle-report.md](../RUNS/)

---

## How This Is Generated

**Extraction method:**
- Asset registry is **derived** from all component documentation
- Each component documented contributes an entry to `assets.yaml`
- Lifecycle state is computed by comparing current run to previous run:
  - **Active:** Component exists in both runs (or is new and now stable)
  - **Added:** Component exists in current run but not in previous run
  - **Removed:** Component exists in previous run but not in current run

**Asset entry structure:**
```yaml
# assets.yaml
assets:
  - id: "table:account"
    type: "table"
    name: "Account"
    displayName: "Account"
    state: "active"
    solution: "DevCore"
    lastModified: "2025-12-29T12:34:56Z"
    metadata:
      schemaName: "account"
      primaryKey: "accountid"
  
  - id: "flow:update-opportunity"
    type: "flow"
    name: "Update Opportunity Revenue"
    displayName: "Update Opportunity Revenue"
    state: "added"                      # New in this run
    solution: "DevCore"
    lastModified: "2025-12-29T14:22:10Z"
    metadata:
      triggerType: "automated"
      enabled: true
```

**Lifecycle state transitions:**
```
(does not exist) → "added" → "active"
"active" → "removed" (if deleted from environment)
"removed" → "added" (if re-added to environment)
```

**Solution membership:**
- Components belong to one or more solutions
- Solution membership extracted from Dataverse solution metadata
- Solutions classified as:
  - **DevCore:** Core custom solution components
  - **ProdOnly:** Production-only components (not in dev)
  - **OOB:** Out-of-box (Microsoft-provided) components

**Read-only guarantees:**
- All extraction is read-only; no modifications are made to the environment
- Generation is deterministic given the same component documentation

**Update frequency:**
- Nightly runs (full refresh)
- Post-import runs (incremental updates after solution imports)

---

## Asset Lifecycle & Change Detection

### Lifecycle states:

| State | Meaning | Example |
|-------|---------|---------|
| `active` | Component exists and is stable | Table documented in both current and previous runs |
| `added` | Component is new in this run | New flow created since last documentation run |
| `removed` | Component was deleted since last run | Plugin unregistered or deleted |

### Change detection process:

1. **Baseline:** Previous run's `assets.yaml` is the baseline
2. **Current run:** New documentation generates a new `assets.yaml`
3. **Comparison:** Assets are compared by `id`:
   - If in current but not baseline → `state: added`
   - If in baseline but not current → `state: removed`
   - If in both → `state: active`
4. **Lifecycle report:** Detailed changes documented in [/RUNS/{latest}/lifecycle-report.md](../RUNS/)

### What triggers state changes:

**State: added**
- New table, flow, plugin, queue, SLA, or workstream created
- Previously undocumented component now documented (e.g., filter change)
- Component re-added after being removed

**State: removed**
- Component deleted from environment
- Component removed from solution
- Component excluded by filter (e.g., user queue exclusion)

**State: active**
- Component exists in both current and previous runs
- Component may have been modified (check `lastModified` timestamp)

---

## Coverage & Limitations

### High confidence:
- Asset existence (component is present in environment)
- Asset type (table, flow, plugin, etc.)
- Solution membership

### Moderate confidence:
- Lifecycle state (depends on previous run availability)
- Last modified timestamp (depends on metadata accuracy)

### Known gaps:
- **First run:** All components will be `state: active` (no baseline to compare)
- **Renamed components:** May appear as "removed" + "added" (not detected as rename)
- **Filtering changes:** If filters change (e.g., include more queues), components may appear "added" even if they existed before

**Where to check coverage:**
- [/RUNS/{latest}/coverage-report.md](../RUNS/)
- [/AIDocumentation/_quality/gap-matrix.md](../_quality/gap-matrix.md)

---

## Guidance for Copilot Agents

### Where to look for structured truth:

| Question | File Path |
|----------|-----------|
| What components exist? | `_registry/assets.yaml` → list all assets |
| Does component X exist? | `_registry/assets.yaml` → search by `id` or `name` |
| What components were added recently? | `_registry/assets.yaml` → filter by `state: added` |
| What components were removed recently? | `_registry/assets.yaml` → filter by `state: removed` |
| What solution does component X belong to? | `_registry/assets.yaml` → find component → `solution` field |
| What components are in solution Y? | `_registry/solutions.yaml` → look up solution → list components |

### Where to look for explanations:
- [/RUNS/{latest}/lifecycle-report.md](../RUNS/) → Detailed change analysis
- Component-specific READMEs → [/tables/](../tables/), [/flows/](../flows/), [/plugins/](../plugins/), etc.

### Common patterns:

**Asset lookup by type:**
```yaml
# assets.yaml
assets:
  - id: "table:account"
    type: "table"
    name: "Account"
    state: "active"
  
  - id: "flow:update-opportunity"
    type: "flow"
    name: "Update Opportunity Revenue"
    state: "added"
  
  - id: "plugin:RevOps.SolutionPlugins.AccountPlugin"
    type: "plugin"
    name: "AccountPlugin"
    state: "active"
```

**Solution membership:**
```yaml
# solutions.yaml
solutions:
  - name: "DevCore"
    displayName: "RevOps Core Solution"
    publisher: "RevOps"
    version: "1.2.3.4"
    components:
      - "table:cr972_pricingsheet"
      - "flow:update-opportunity"
      - "plugin:RevOps.SolutionPlugins.AccountPlugin"
  
  - name: "ProdOnly"
    displayName: "Production-Only Components"
    publisher: "RevOps"
    version: "1.0.0.0"
    components:
      - "flow:prod-only-workflow"
```

**Lifecycle state filtering:**
```yaml
# Example: Find all added components
assets:
  - id: "table:cr972_newentity"
    type: "table"
    name: "New Entity"
    state: "added"                    # NEW
  
  - id: "flow:legacy-workflow"
    type: "flow"
    name: "Legacy Workflow"
    state: "removed"                  # DELETED
```

### Confidence indicators:
- **High confidence:** Asset existence, type, solution membership
- **Moderate confidence:** Lifecycle state (depends on baseline availability)
- **Low confidence:** Renamed or moved components (may appear as removed + added)

### When to use the asset registry:

**Use the registry when:**
- You need to verify if a component exists
- You need to list all components of a type
- You need to find recently added or removed components
- You need to check solution membership

**Use the dependency graph when:**
- You need to understand relationships between components
- You need to perform impact analysis

**Use component-specific docs when:**
- You need detailed metadata for a component
- You need narrative explanations or business logic

### Asset registry workflow:

1. **Inventory check:** Open [assets.yaml](assets.yaml) and search for component by `id` or `name`
2. **Verify existence:** Check `state` field (if `removed`, component no longer exists)
3. **Check solution membership:** See `solution` field to understand where component is deployed
4. **Review lifecycle changes:** See [/RUNS/{latest}/lifecycle-report.md](../RUNS/) for detailed change analysis
5. **Navigate to component docs:** Use component `id` to locate detailed documentation (e.g., `table:account` → `/tables/account/README.md`)

---

## Special Considerations

### First run (no baseline):
- On the first documentation run, there is no previous `assets.yaml` to compare
- All components will have `state: active` (no `added` or `removed` states)
- Lifecycle tracking begins on the second run

### Renamed components:
- If a component is renamed, it will appear as:
  - Old name: `state: removed`
  - New name: `state: added`
- Rename detection is not automatic; requires manual correlation

### Filtering changes:
- If inclusion/exclusion filters change (e.g., [/AIDocumentation/_config/queues.yaml]), components may appear `added` or `removed` even if they existed before
- Check [/RUNS/{latest}/run-summary.md](../RUNS/) for filter changes

### Solution comparison (Dev vs Prod):
- To compare Dev and Prod environments, compare `assets.yaml` from each environment's latest run
- See [/RUNS/{latest}/environment-comparison.md](../RUNS/) for automated comparison reports

### Performance considerations:
- `assets.yaml` can be large (thousands of entries)
- For fast lookups, consider indexing by `id` or `type`
- Use `solutions.yaml` for solution-level queries

---

**Last updated:** Derived at runtime  
**Schema version:** See latest run in [/RUNS/](../RUNS/)
