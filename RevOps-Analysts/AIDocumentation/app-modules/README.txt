TITLE
=====
RevOps - App Modules Overview

PURPOSE
-------
This folder contains documentation for all model-driven app modules in the RevOps environment. App modules define the user experience, including entities, dashboards, and business process flows.

Audience:
- RevOps developers and solution architects
- Copilot agents performing analysis and impact assessment
- Business analysts understanding system capabilities

SCOPE
-----
Each app module has its own subfolder containing:

- README.md: App purpose, target audience, and key components
- facts/entities.yaml: Tables included in the app with their views and forms
- facts/components.yaml: Dashboards, business process flows, and other components

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
To find a specific app:
- Browse subfolders by app unique name (normalized with hyphens, lowercase)

To understand app composition:
- Check facts/entities.yaml for included tables
- Review facts/components.yaml for dashboards and BPFs

COMMON QUESTIONS THIS ANSWERS
-----------------------------


LIMITATIONS
-----------
