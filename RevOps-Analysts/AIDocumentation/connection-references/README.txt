TITLE
=====
RevOps - Connection References Overview

PURPOSE
-------
This folder contains documentation for all connection references in the RevOps environment. Connection references enable flows and other components to connect to external services (Dataverse, SharePoint, Teams, Azure, etc.).

Audience:
- RevOps developers and solution architects
- Copilot agents performing analysis and impact assessment
- Business analysts understanding system capabilities

SCOPE
-----
Each connection reference has its own subfolder containing:

- README.md: Connection reference purpose and connector type
- facts/connection-info.yaml: Connection metadata, connector details, and solution membership

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
To find a specific connection reference:
- Browse subfolders by connection reference name (normalized with hyphens, lowercase)

To understand connection usage:
- Check which flows use the connection in /flows/ folder
- Review facts/connection-info.yaml for connector details

COMMON QUESTIONS THIS ANSWERS
-----------------------------


LIMITATIONS
-----------
