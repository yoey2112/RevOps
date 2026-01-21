TITLE
=====
RevOps -  Shared Overview

PURPOSE
-------
This folder contains shared documentation standards, naming conventions, and normalization rules used across all component documentation. The shared folder ensures consistency in how components are documented, named, and structured.

Audience:
- Documentation pipeline maintainers implementing extraction logic
- Copilot agents understanding naming conventions and standards
- Developers contributing to documentation generation
- Solution architects ensuring documentation consistency

SCOPE
-----
The shared/ folder contains:

- standards.md: Documentation standards, formatting rules, and quality guidelines
- normalization.md: Naming conventions, ID formats, and data normalization rules

REVOPS STANDARD
---------------
- All documentation follows a consistent structure with _facts folders for structured data
- Dependency relationships tracked in _graph for impact analysis
- Asset registry in _registry catalogs all components
- Extraction runs logged in RUNS folder with timestamps and coverage reports

HOW TO NAVIGATE
---------------
To understand documentation standards:
- Open standards.md
- Review formatting guidelines, structure requirements, and quality criteria

To understand naming conventions:
- Open normalization.md
- Review node ID formats, folder naming rules, and data normalization approaches

COMMON QUESTIONS THIS ANSWERS
-----------------------------
### Where to Look for Structured Truth

For documentation standards:

/shared/standards.md

Contains: Formatting rules, required sections, quality criteria, markdown conventions

For naming conventions:

/shared/normalization.md

Contains: Node ID formats, folder naming rules, special character handling, date/timestamp formats

LIMITATIONS
-----------
