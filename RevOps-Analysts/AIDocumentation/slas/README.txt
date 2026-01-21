TITLE
=====
RevOps - Slas Overview

PURPOSE
-------
This folder contains documentation for all Service Level Agreements (SLAs) configured in the RevOps environment. SLAs define time-based performance targets and warning thresholds for case resolution.

Audience:
- RevOps developers and solution architects
- Copilot agents performing analysis and impact assessment
- Business analysts understanding system capabilities

SCOPE
-----
Each SLA has its own subfolder containing:

- README.md: SLA purpose, target times, and applicability rules
- facts/sla-info.yaml: SLA configuration, KPI targets, workflow associations
- facts/items.yaml: SLA items with warning/failure times and conditions

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
To find a specific SLA:
- Browse subfolders by SLA name (normalized with hyphens, lowercase)

To understand SLA rules:
- Check facts/sla-info.yaml for applicability conditions
- Review facts/items.yaml for warning/failure thresholds

COMMON QUESTIONS THIS ANSWERS
-----------------------------


LIMITATIONS
-----------
