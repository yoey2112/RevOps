TITLE
=====
RevOps - Plugins Overview

PURPOSE
-------
This folder contains documentation for all server-side .NET plugins registered in the RevOps environment. Plugins execute within the Dataverse event pipeline to implement custom business logic, validation, and data transformation.

Audience:
- RevOps developers and solution architects
- Copilot agents performing analysis and impact assessment
- Business analysts understanding system capabilities

SCOPE
-----
Each plugin assembly has its own subfolder containing:

- README.md: Overview of plugin purpose and registered SDK steps
- facts/sdk-steps.yaml: Detailed step configurations (table, message, stage, mode, rank)
- facts/images.yaml: Pre-image and post-image configurations
- facts/dependencies.yaml: Tables and fields accessed by the plugin

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
To find a specific plugin:
- Browse subfolders by assembly name (e.g., revops-emailplugins/, revops-solutionplugins/)

To understand what triggers a plugin:
- Check facts/sdk-steps.yaml for table, message (Create, Update, etc.), and stage (PreValidation, PreOperation, PostOperation)
- Review /graph/dependencies.json for impact analysis

COMMON QUESTIONS THIS ANSWERS
-----------------------------


LIMITATIONS
-----------
