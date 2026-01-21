# Dependency Graph Documentation

## Purpose

This folder contains the unified dependency graph for the entire RevOps environment. The dependency graph models relationships between all components (tables, flows, plugins, queues, SLAs, workstreams), enabling impact analysis, traceability, and architectural understanding.

**Audience:**
- RevOps developers assessing change impact before modifications
- Copilot agents performing dependency and cross-component analysis
- Solution architects reviewing system architecture
- Engineers troubleshooting cascading failures or performance issues

## What's Documented Here

The `_graph/` folder contains:

- **dependencies.json**: Complete dependency graph with nodes (components) and edges (relationships)
- **reverse-index.yaml**: Optimized "what uses X" lookup index
- **solution-dependencies.yaml**: Solution membership for all components
- **IMPACT-ANALYSIS.md**: Guide to performing impact analysis workflows

## How to Navigate

**To find what a component depends on:**
- Open [dependencies.json](dependencies.json)
- Locate the node for your component (e.g., `table:account`, `flow:update-opportunity`)
- Review its `edges` array for outgoing dependencies

**To find what depends on a component ("what uses this"):**
- Open [reverse-index.yaml](reverse-index.yaml)
- Look up the component ID
- See all components that reference it

**To understand solution membership:**
- Open [solution-dependencies.yaml](solution-dependencies.yaml)
- Find component to see which solution(s) it belongs to

**To perform impact analysis:**
- Read [IMPACT-ANALYSIS.md](IMPACT-ANALYSIS.md) for step-by-step guidance
- Use dependency graph to trace upstream and downstream impacts
- Check confidence scores to assess reliability

## How This Is Generated

The dependency graph is derived from all component documentation:
- **Tables**: Contribute relationship edges (1:N, N:1, N:N)
- **Flows**: Contribute read/write edges to tables
- **Plugins**: Contribute trigger edges (table + message → plugin)
- **Queues/SLAs/Workstreams**: Contribute routing/assignment edges

**Node/edge model:**
```json
{
  "nodes": [
    {"id": "table:account", "type": "table", "label": "Account"},
    {"id": "flow:update-opp", "type": "flow", "label": "Update Opportunity"}
  ],
  "edges": [
    {"source": "flow:update-opp", "target": "table:opportunity", "type": "writes", "confidence": "high"}
  ]
}
```

**Confidence scoring:**
- **High**: Direct metadata extraction (table relationships, plugin registrations)
- **Moderate**: Inferred from configuration (flow actions, SLA associations)
- **Low**: Best-effort parsing (complex expressions, dynamic references)

**Guarantees:**
- Read-only extraction — no modifications to environment
- Deterministic generation — same input produces same output
- Deduplicated edges

## Dependency & Cross-Reference Notes

**The dependency graph models:**
- **Table-to-table**: 1:N, N:1, N:N relationships
- **Flow-to-table**: Reads (Get/List) and writes (Create/Update/Delete)
- **Plugin-to-table**: Triggers (table + message fires plugin)
- **Queue-to-workstream**: Workstream routes to queue
- **SLA-to-queue**: SLA applies to queue items
- **Flow-to-flow**: Parent flow calls child flow

**Common patterns:**
- Table lookup → Parent table dependency
- Flow reads table → Query dependency
- Plugin fires on table Create → Trigger dependency
- Workstream routes to queue → Routing dependency

## Coverage & Limitations

**High Confidence:**
- ✅ Table-to-table relationships (all types)
- ✅ Plugin trigger registrations
- ✅ Flow-to-table read/write operations (standard actions)

**Moderate Confidence:**
- ⚠️ Queue-to-workstream routing rules
- ⚠️ SLA-to-queue associations
- ⚠️ Flow-to-flow calls (child flow invocations)

**Limitations:**
- ❌ Dynamic references (table names from variables)
- ❌ Complex expressions in flows (may be incomplete)
- ❌ Plugin side effects (what plugins write internally — requires code inspection)
- ❌ External system integrations (documented as edges but not fully traced)

**To verify coverage:**
- Check [../RUNS/latest/coverage-report.md](../RUNS/) for graph statistics

## Guidance for Copilot Agents

### Where to Look for Structured Truth

**For component dependencies:**
```
/_graph/dependencies.json
```
Node structure: `{id, type, label, metadata}` Edge structure: `{source, target, type, confidence}`

**For reverse dependencies:**
```
/_graph/reverse-index.yaml
```
Format: `{component-id: [dependent1, dependent2, ...]}`

**For solution membership:**
```
/_graph/solution-dependencies.yaml
```
Format: `{component-id: [solution1, solution2]}`

### Common Question → File Path Mappings

| Question | File Path |
|----------|-----------|
| What does component X depend on? | `_graph/dependencies.json` (find node → edges) |
| What depends on component X? | `_graph/reverse-index.yaml` (lookup component) |
| What flows write to table Y? | `_graph/dependencies.json` (filter edges: target=table:Y, type=writes) |
| What plugins fire on table Y? | `_graph/dependencies.json` (filter edges: target=table:Y, sourceType=plugin) |
| What solution owns component X? | `_graph/solution-dependencies.yaml` (lookup component) |

### Critical Concepts for Dependency Graph

**Node ID format:**
- `table:{logical-name}` (e.g., table:account, table:revops_pricing)
- `flow:{flow-name}` (e.g., flow:update-opportunity)
- `plugin:{plugin-type}` (e.g., plugin:RevOps.SolutionPlugins.AccountPlugin)
- `queue:{queue-name}` (e.g., queue:support-tier-1)
- `sla:{sla-name}` (e.g., sla:response-4-hours)
- `workstream:{workstream-name}` (e.g., workstream:live-chat-sales)

**Edge types:**
- `reads`: Flow/plugin reads table
- `writes`: Flow/plugin writes table
- `triggers`: Table event triggers plugin
- `relates-to`: Table-to-table relationship
- `routes-to`: Workstream routes to queue
- `applies-to`: SLA applies to queue
- `calls`: Flow calls child flow

**Confidence values:**
- `high`: Direct metadata extraction
- `moderate`: Inferred from configuration
- `low`: Best-effort parsing

### Usage Patterns

**When tracing impact of table changes:**
1. Find table node in dependencies.json
2. Use reverse-index.yaml to identify all dependents
3. For each dependent, assess impact based on type (flow/plugin/form)
4. Check confidence scores — low confidence requires manual verification

**When analyzing flow dependencies:**
1. Find flow node in dependencies.json
2. Review outgoing edges for tables read/written
3. Navigate to table docs to understand field requirements
4. Check for child flow calls (edges with type: calls)

**When investigating cascading plugin execution:**
1. Find plugin node in dependencies.json
2. Check trigger edges (what fires the plugin)
3. If plugin writes tables, check those tables for additional plugins
4. Note: Plugin side effects require source code inspection
2. Look up your component (e.g., `table:incident`)
3. See all components that reference it

### Finding solution membership:
1. Open [solution-dependencies.yaml](solution-dependencies.yaml)
2. Look up your component to see which solution(s) it belongs to

### Performing impact analysis:
1. Read [IMPACT-ANALYSIS.md](IMPACT-ANALYSIS.md) for step-by-step guidance
2. Use the dependency graph to trace upstream and downstream impacts
3. Check confidence scores to assess reliability of dependency data

### Cross-references:
- **Component documentation:** [/AIDocumentation/tables/](../tables/), [/flows/](../flows/), [/plugins/](../plugins/), etc.
- **Asset registry:** [/_registry/assets.yaml](../_registry/assets.yaml)
- **Latest extraction run:** [/RUNS/](../RUNS/)

---

## How This Is Generated

**Extraction method:**
- Dependency graph is **derived** from all component documentation
- Each component folder contributes nodes and edges:
  - **Tables:** Contribute relationship edges (1:N, N:1, N:N)
  - **Flows:** Contribute read/write edges to tables
  - **Plugins:** Contribute trigger edges (table + message → plugin)
  - **Queues, SLAs, workstreams:** Contribute routing/assignment edges
- Edges are deduplicated and enriched with confidence scores

**Node/edge model:**
```json
{
  "nodes": [
    {
      "id": "table:account",
      "type": "table",
      "label": "Account",
      "metadata": { ... }
    },
    {
      "id": "flow:update-opportunity",
      "type": "flow",
      "label": "Update Opportunity Revenue",
      "metadata": { ... }
    }
  ],
  "edges": [
    {
      "source": "flow:update-opportunity",
      "target": "table:opportunity",
      "type": "writes",
      "confidence": "high"
    }
  ]
}
```

**Confidence scoring:**
- **High confidence:** Direct metadata extraction (e.g., table relationships, plugin registrations)
- **Moderate confidence:** Inferred from configuration (e.g., flow actions, SLA associations)
- **Low confidence:** Best-effort parsing (e.g., complex expressions, dynamic references)

**Read-only guarantees:**
- All extraction is read-only; no modifications are made to the environment
- Generation is deterministic given the same component documentation

**Update frequency:**
- Nightly runs (full refresh)
- Post-import runs (incremental updates after solution imports)

---

## Dependency & Cross-Reference Notes

The dependency graph models the following relationship types:

### Table-to-table relationships:
- **1:N (one-to-many):** Parent table → child table (e.g., `account` → `contact`)
- **N:1 (many-to-one):** Child table → parent table (e.g., `incident` → `account`)
- **N:N (many-to-many):** Via intersection table (e.g., `opportunity` ↔ `product`)

### Flow-to-table relationships:
- **Reads:** Flow queries table data (e.g., "List rows", "Get row")
- **Writes:** Flow modifies table data (e.g., "Create row", "Update row", "Delete row")

### Plugin-to-table relationships:
- **Trigger:** Table event triggers plugin (e.g., `incident` Create → plugin X)
- **Filtering attributes:** Specific columns that trigger plugin (Update messages only)

### Queue-to-workstream relationships:
- **Routes to:** Workstream routes items to queue

### SLA-to-queue relationships:
- **Applies to:** SLA applies to items in queue

### Flow-to-flow relationships:
- **Calls:** Parent flow invokes child flow

### Solution membership:
- Components belong to solutions (DevCore, ProdOnly, OOB)

---

## Coverage & Limitations

### High confidence:
- Table-to-table relationships (all types)
- Plugin trigger registrations
- Flow-to-table read/write operations (for standard actions)

### Moderate confidence:
- Queue-to-workstream routing rules
- SLA-to-queue associations
- Flow-to-flow calls (child flow invocations)

### Low confidence:
- Dynamic references (e.g., table names from variables)
- Complex expressions in flows
- Plugin side effects (what plugins write internally)

### Known gaps:
- Custom routing logic in plugins or flows (not inferred)
- External system integrations (e.g., REST API calls) are documented as edges but not fully traced
- Circular dependencies are detected but may require manual review

**Where to check coverage:**
- [/RUNS/{latest}/coverage-report.md](../RUNS/)
- [/AIDocumentation/_quality/gap-matrix.md](../_quality/gap-matrix.md)

---

## Guidance for Copilot Agents

### Where to look for structured truth:

| Question | File Path |
|----------|-----------|
| What does component X depend on? | `_graph/dependencies.json` → find node → `edges` array |
| What depends on component X? | `_graph/reverse-index.yaml` → look up component → see dependents |
| What flows write to table Y? | `_graph/dependencies.json` → filter edges by `target: table:Y, type: writes` |
| What plugins fire on table Y? | `_graph/dependencies.json` → filter edges by `target: table:Y, sourceType: plugin` |
| What solution does component X belong to? | `_graph/solution-dependencies.yaml` → look up component |

### Where to look for explanations:
- [IMPACT-ANALYSIS.md](IMPACT-ANALYSIS.md) → How to perform impact analysis
- Component-specific READMEs → [/tables/](../tables/), [/flows/](../flows/), [/plugins/](../plugins/), etc.

### Common patterns:

**Node ID format:**
- `table:{logical-name}` (e.g., `table:account`, `table:cr972_pricingsheet`)
- `flow:{flow-name-or-id}` (e.g., `flow:update-opportunity`)
- `plugin:{plugin-type-name}` (e.g., `plugin:RevOps.SolutionPlugins.AccountPlugin`)
- `queue:{queue-name}` (e.g., `queue:support-tier-1`)
- `sla:{sla-name}` (e.g., `sla:response-within-4-hours`)
- `workstream:{workstream-name}` (e.g., `workstream:live-chat-sales`)

**Edge types:**
- `reads` (flow/plugin reads table)
- `writes` (flow/plugin writes table)
- `triggers` (table event triggers plugin)
- `relates-to` (table-to-table relationship)
- `routes-to` (workstream routes to queue)
- `applies-to` (SLA applies to queue)
- `calls` (flow calls child flow)

**Confidence values:**
- `high` (direct metadata extraction)
- `moderate` (inferred from configuration)
- `low` (best-effort parsing)

**Example graph query (conceptual):**
```
Question: What flows write to the 'incident' table?

1. Open dependencies.json
2. Filter edges where:
   - target = "table:incident"
   - type = "writes"
   - sourceType = "flow"
3. Collect source node IDs (e.g., ["flow:create-case", "flow:escalate-case"])
4. For each flow, navigate to /flows/{flow-name}/README.md for details
```

### Confidence indicators:
- Always check the `confidence` field on edges
- High-confidence edges are reliable for automated decisions
- Low-confidence edges require manual verification

### When to use the dependency graph:

**Use the graph when:**
- You need to trace dependencies across component types (e.g., table → flows → plugins)
- You need to perform impact analysis before a change
- You need to answer "what uses this" or "what does this use"
- You need to understand cross-solution dependencies

**Use component-specific docs when:**
- You need detailed metadata for a single component (e.g., column types, flow actions)
- You need narrative explanations or business logic
- You need to understand component-specific configurations

### Impact analysis workflow:

1. **Identify the component you're changing** (e.g., adding a column to `incident` table)
2. **Use reverse-index.yaml** to find all dependents (e.g., flows that read/write `incident`, plugins that fire on `incident`)
3. **For each dependent, assess impact:**
   - **Flows:** Check if they use the column you're adding/removing
   - **Plugins:** Check if filtering attributes include the column
   - **Forms:** Check if the column is on any form layouts
4. **Trace cascading impacts:** If you change a flow, check what tables it writes to, then repeat the process
5. **Document findings:** Use the impact analysis report template in [IMPACT-ANALYSIS.md](IMPACT-ANALYSIS.md)

---

## Special Considerations

### Circular dependencies:
- Circular dependencies are possible (e.g., flow A calls flow B, flow B calls flow A)
- The dependency graph does not prevent or remove circular dependencies
- Check [/AIDocumentation/_quality/gap-matrix.md](../_quality/gap-matrix.md) for circular dependency warnings

### Solution boundaries:
- Components may belong to multiple solutions (e.g., shared libraries)
- Use [solution-dependencies.yaml](solution-dependencies.yaml) to understand solution membership
- Cross-solution dependencies are flagged for review

### External system dependencies:
- External API calls (REST, SOAP) are modeled as edges but not fully traced
- Target systems are identified by connection reference or URL
- Full external dependency mapping requires manual documentation

### Performance considerations:
- `dependencies.json` can be large (hundreds of KB)
- For fast lookups, use `reverse-index.yaml` instead
- If performance is critical, consider caching or indexing the graph

---

**Last updated:** Derived at runtime  
**Schema version:** See latest run in [/RUNS/](../RUNS/)
