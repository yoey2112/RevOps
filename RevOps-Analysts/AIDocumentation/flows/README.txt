TITLE
=====
RevOps - Flows Overview

PURPOSE
-------
This folder contains comprehensive documentation for all Power Automate cloud flows in the RevOps environment. Flows are automated workflows that orchestrate business processes, integrate systems, and respond to events within and beyond the Power Platform ecosystem.

Audience:
- RevOps developers and solution architects
- Copilot agents performing analysis and impact assessment
- Business analysts understanding system capabilities

SCOPE
-----
Each flow has its own subfolder containing:

- README.md: Narrative explanation of flow logic, purpose, and business context
- facts/flow-actions.yaml: Action-by-action breakdown with inputs, outputs, and table operations
- facts/metadata.yaml: Flow trigger type, state, owner, and solution membership
- facts/dependencies.yaml: Extracted dependencies on tables, connection references, and child flows

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
To find a specific flow:
- Browse subfolders by display name (normalized with hyphens, lowercase)
- Flow folders may include prefix indicators for categorization

To understand what a flow does:
- Start with the README.md for business context and high-level logic
- Review facts/flow-actions.yaml for step-by-step action breakdown
- Check facts/dependencies.yaml for table and connection dependencies

COMMON QUESTIONS THIS ANSWERS
-----------------------------


LIMITATIONS
-----------
