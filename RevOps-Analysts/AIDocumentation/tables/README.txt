TITLE
=====
RevOps - Tables Overview

PURPOSE
-------
This folder contains comprehensive documentation for all Dataverse tables (entities) in the RevOps environment. Tables are the foundational data structures that store business information - from standard entities like Account and Contact to custom RevOps-specific tables.

Audience:
- RevOps developers and solution architects
- Copilot agents performing analysis and impact assessment
- Business analysts understanding system capabilities

SCOPE
-----
Each table has its own subfolder containing:

- README.md: Narrative documentation explaining purpose, usage, and key relationships
- facts/columns.yaml: Machine-readable column metadata (names, types, descriptions, required fields)
- facts/relationships.yaml: All 1:N, N:1, and N:N relationships with other tables
- facts/forms.yaml: Form configurations including fields, tabs, and sections (best-effort)
- facts/businessrules.yaml: Business rules configured on the table (best-effort)

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
To find a specific table:
- Browse subfolders by logical name (e.g., account/, revopspricingrequest/)
- Standard Dynamics 365 tables use lowercase names (account, contact, opportunity)
- Custom RevOps tables are prefixed with revops

To understand table relationships:
- Check the table's facts/relationships.yaml for direct connections
- See /graph/dependencies.json for full dependency graph
- Review /graph/reverse-index.yaml to find what components use a table

COMMON QUESTIONS THIS ANSWERS
-----------------------------


LIMITATIONS
-----------
