# Shared Documentation Standards

## Purpose

This folder contains shared documentation standards, naming conventions, and normalization rules used across all component documentation. The _shared folder ensures consistency in how components are documented, named, and structured.

**Audience:**
- Documentation pipeline maintainers implementing extraction logic
- Copilot agents understanding naming conventions and standards
- Developers contributing to documentation generation
- Solution architects ensuring documentation consistency

## What's Documented Here

The `_shared/` folder contains:

- **standards.md**: Documentation standards, formatting rules, and quality guidelines
- **normalization.md**: Naming conventions, ID formats, and data normalization rules

## How to Navigate

**To understand documentation standards:**
- Open [standards.md](standards.md)
- Review formatting guidelines, structure requirements, and quality criteria

**To understand naming conventions:**
- Open [normalization.md](normalization.md)
- Review node ID formats, folder naming rules, and data normalization approaches

## How This Is Generated

Shared standards are manually maintained by the documentation team:
- Standards evolved from best practices and lessons learned
- Normalization rules ensure consistent component identification
- Guidelines updated as new component types are added

**Guarantees:**
- Standards are version-controlled and reviewed
- Changes to standards trigger pipeline updates
- Normalization rules applied consistently across all extractions

## Guidance for Copilot Agents

### Where to Look for Structured Truth

**For documentation standards:**
```
/_shared/standards.md
```
Contains: Formatting rules, required sections, quality criteria, markdown conventions

**For naming conventions:**
```
/_shared/normalization.md
```
Contains: Node ID formats, folder naming rules, special character handling, date/timestamp formats

### Common Question → File Path Mappings

| Question | File Path |
|----------|-----------|
| How should component IDs be formatted? | `_shared/normalization.md` → Node ID formats |
| What sections are required in README? | `_shared/standards.md` → README structure |
| How are component names normalized? | `_shared/normalization.md` → Name normalization |
| What are the quality standards? | `_shared/standards.md` → Quality guidelines |

### Usage Patterns

**When generating documentation:**
1. Consult standards.md for required sections and formatting
2. Apply normalization.md rules for component IDs and folder names
3. Ensure generated content meets quality criteria

**When validating documentation:**
1. Check standards.md for compliance requirements
2. Verify naming conventions match normalization.md rules
3. Validate required sections are present

**When contributing to pipeline:**
1. Review standards.md before implementing new extractors
2. Follow normalization.md for consistent ID generation
3. Update standards as needed (with team review)
