TITLE
=====
RevOps - Business Process Flows Overview

PURPOSE
-------
This folder contains documentation for all Business Process Flows (BPFs) in the RevOps environment. BPFs guide users through defined business processes by presenting stages, steps, and required fields in a structured workflow.

Audience:
- RevOps developers and solution architects
- Copilot agents performing analysis and impact assessment
- Business analysts understanding system capabilities

SCOPE
-----
Each business process flow has its own subfolder containing:

- README.md: BPF purpose, stages, and business context
- facts/bpf-info.yaml: BPF metadata (name, category, primary entity, status)
- facts/stages.yaml: Process stages with steps, fields, and transitions
- facts/entities.yaml: Tables/entities participating in the BPF

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
To find a specific BPF:
- Browse subfolders by BPF name (normalized with hyphens, lowercase)

To understand BPF stages:
- Review facts/stages.yaml for stage sequence, required fields, and transitions
- Check facts/entities.yaml for participating tables

COMMON QUESTIONS THIS ANSWERS
-----------------------------


LIMITATIONS
-----------
