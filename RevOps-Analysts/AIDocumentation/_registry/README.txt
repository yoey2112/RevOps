TITLE
=====
RevOps -  Registry Overview

PURPOSE
-------
This folder contains the asset registry for the RevOps environment. The asset registry is a canonical inventory of all documented components, tracking lifecycle state (active, removed, added), solution membership, and metadata. It serves as the single source of truth for "what exists" and powers change detection across documentation runs.

Audience:
- RevOps developers verifying solution contents before/after imports
- Copilot agents answering "what exists" and lifecycle queries
- Solution architects reviewing cross-environment differences
- Engineers performing change impact analysis

SCOPE
-----
The registry/ folder contains:

- assets.yaml: Complete inventory of all documented components with lifecycle state
- solutions.yaml: Solution definitions and component membership metadata

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
To find all components of a type:
- Open assets.yaml
- Filter by type field (table, flow, plugin, queue, sla, workstream, etc.)

To check if a component exists:
- Open assets.yaml
- Search by id or name
- Check state field: active, removed, or added

To find components by solution:
- Open solutions.yaml
- Locate solution → see all member components

To track lifecycle changes:
- Compare current run's assets.yaml with previous run
- added: Component new in this run
- removed: Component present in previous run but missing now
- active: Component present in both runs
1. Open solutions.yaml
2. Look up the solution (e.g., DevCore, ProdOnly)
3. See all components in that solution

COMMON QUESTIONS THIS ANSWERS
-----------------------------
### Where to look for structured truth:

| Question | File Path |
|----------|-----------|
| What components exist? | registry/assets.yaml → list all assets |
| Does component X exist? | registry/assets.yaml → search by id or name |
| What components were added recently? | registry/assets.yaml → filter by state: added |
| What components were removed recently? | registry/assets.yaml → filter by state: removed |
| What solution does component X belong to? | registry/assets.yaml → find component → solution field |
| What components are in solution Y? | registry/solutions.yaml → look up solution → list components |

LIMITATIONS
-----------
