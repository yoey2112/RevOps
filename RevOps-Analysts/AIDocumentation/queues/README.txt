TITLE
=====
RevOps - Queues Overview

PURPOSE
-------
This folder contains documentation for all Dataverse queues used for work distribution and case routing in the RevOps environment. Queues organize work items and enable team-based assignment.

Audience:
- RevOps developers and solution architects
- Copilot agents performing analysis and impact assessment
- Business analysts understanding system capabilities

SCOPE
-----
Each queue has its own subfolder containing:

- README.md: Queue purpose, membership, and routing configuration
- facts/queue-info.yaml: Queue type (public/private), owner, email settings
- facts/members.yaml: User and team memberships

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
To find a specific queue:
- Browse subfolders by queue name (normalized with hyphens, lowercase)

To understand queue routing:
- Check facts/queue-info.yaml for queue type and configuration
- Review workstream associations in /workstreams/ folder

COMMON QUESTIONS THIS ANSWERS
-----------------------------


LIMITATIONS
-----------
