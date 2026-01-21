TITLE
=====
RevOps - Workstreams Overview

PURPOSE
-------
This folder contains documentation for all Omnichannel workstreams in the RevOps environment. Workstreams define routing rules, assignment logic, and channel configurations for customer service interactions.

Audience:
- RevOps developers and solution architects
- Copilot agents performing analysis and impact assessment
- Business analysts understanding system capabilities

SCOPE
-----
Each workstream has its own subfolder containing:

- README.md: Workstream purpose, channel type, and routing strategy
- facts/workstream-info.yaml: Workstream configuration, capacity profiles, work distribution
- facts/routing-rules.yaml: Priority-based routing rules and conditions

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
To find a specific workstream:
- Browse subfolders by workstream name (normalized with hyphens, lowercase)

To understand routing logic:
- Check facts/routing-rules.yaml for rule priority and conditions
- Review queue associations in /queues/ folder

COMMON QUESTIONS THIS ANSWERS
-----------------------------


LIMITATIONS
-----------
