TITLE
=====
RevOps -  Graph Overview

PURPOSE
-------
This folder contains the unified dependency graph for the entire RevOps environment. The dependency graph models relationships between all components (tables, flows, plugins, queues, SLAs, workstreams), enabling impact analysis, traceability, and architectural understanding.

Audience:
- RevOps developers assessing change impact before modifications
- Copilot agents performing dependency and cross-component analysis
- Solution architects reviewing system architecture
- Engineers troubleshooting cascading failures or performance issues

SCOPE
-----
The graph/ folder contains:

- dependencies.json: Complete dependency graph with nodes (components) and edges (relationships)
- reverse-index.yaml: Optimized "what uses X" lookup index
- solution-dependencies.yaml: Solution membership for all components
- IMPACT-ANALYSIS.md: Guide to performing impact analysis workflows

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
To find what a component depends on:
- Open dependencies.json
- Locate the node for your component (e.g., table:account, flow:update-opportunity)
- Review its edges array for outgoing dependencies

To find what depends on a component ("what uses this"):
- Open reverse-index.yaml
- Look up the component ID
- See all components that reference it

To understand solution membership:
- Open solution-dependencies.yaml
- Find component to see which solution(s) it belongs to

To perform impact analysis:
- Read IMPACT-ANALYSIS.md for step-by-step guidance
- Use dependency graph to trace upstream and downstream impacts
- Check confidence scores to assess reliability

COMMON QUESTIONS THIS ANSWERS
-----------------------------
### Where to Look for Structured Truth

For component dependencies:

/graph/dependencies.json

Node structure: {id, type, label, metadata} Edge structure: {source, target, type, confidence}

For reverse dependencies:

/graph/reverse-index.yaml

Format: {component-id: [dependent1, dependent2, ...]}

For solution membership:

/graph/solution-dependencies.yaml

Format: {component-id: [solution1, solution2]}

LIMITATIONS
-----------
