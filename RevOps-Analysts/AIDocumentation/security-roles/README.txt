TITLE
=====
RevOps - Security Roles Overview

PURPOSE
-------
This folder contains documentation for all security roles configured in the RevOps environment. Security roles define permissions, access levels, and privilege assignments for users and teams.

Audience:
- RevOps developers and solution architects
- Copilot agents performing analysis and impact assessment
- Business analysts understanding system capabilities

SCOPE
-----
Each security role has its own subfolder containing:

- README.md: Role purpose, key privileges, and typical user assignments
- facts/privileges.yaml: Detailed privilege assignments (CRUD + depth levels) per table
- facts/role-info.yaml: Role metadata, description, and solution membership

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
To find a specific role:
- Browse subfolders by role name (normalized with hyphens, lowercase)

To understand role permissions:
- Check facts/privileges.yaml for table-level permissions (Create, Read, Write, Delete, Append, AppendTo)
- Depth levels: None, User, Business Unit, Parent-Child BU, Organization

COMMON QUESTIONS THIS ANSWERS
-----------------------------


LIMITATIONS
-----------
