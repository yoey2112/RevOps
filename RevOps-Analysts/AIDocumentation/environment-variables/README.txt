TITLE
=====
RevOps - Environment Variables Overview

PURPOSE
-------
This folder contains documentation for all environment variables in the RevOps environment. Environment variables enable configuration management across environments without hard-coding values.

Audience:
- RevOps developers and solution architects
- Copilot agents performing analysis and impact assessment
- Business analysts understanding system capabilities

SCOPE
-----
Each environment variable has its own subfolder containing:

- README.md: Variable purpose, expected values, and usage context
- facts/variable-info.yaml: Variable type (string, number, JSON), default value, and current value

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
To find a specific environment variable:
- Browse subfolders by variable schema name (normalized with hyphens, lowercase)

To understand variable usage:
- Check which components reference the variable in dependency graph
- Review facts/variable-info.yaml for type and values

COMMON QUESTIONS THIS ANSWERS
-----------------------------


LIMITATIONS
-----------
