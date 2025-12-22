# RevOps Documentation Repository

## Purpose

This repository serves as the **authoritative documentation source** for the RevOps Microsoft Dynamics 365 / Power Platform environment. It is designed to be:

- **Human-readable**: Clear explanations of business logic and technical implementation
- **AI-accessible**: Structured for programmatic parsing and automated maintenance
- **Version-controlled**: Track changes and evolution of the system
- **Scalable**: Easy to extend as new components are added

---

## Folder Structure

```
Documentation/
├── README.md                      ← You are here
├── DOCUMENTATION-SUMMARY.md       ← High-level project summary (created Dec 2025)
│
├── Tables/                        ← Dataverse table documentation
├── Flows/                         ← Power Automate cloud flows
├── Plugins/                       ← C# plugin assemblies (future)
├── Power Pages Site/              ← Portal customizations and components
└── _schemas/                      ← Reusable schemas and templates (future)
```

---

## High-Level Folder Responsibilities

### 📊 **Tables/** - Dataverse Tables
Documents all custom and heavily customized tables in Dataverse:
- Table purpose and business context
- Column definitions
- Relationships
- Forms (model-driven apps)
- Web resources (JavaScript, CSS)

**Who maintains this**: Developers, Power Platform admins, business analysts

---

### 🔄 **Flows/** - Power Automate
Documents cloud flows (automated, instant, scheduled):
- Business triggers
- Logic and decision trees
- Error handling
- Integration points
- Flow schemas (JSON exports)

**Who maintains this**: Flow authors, automation engineers

---

### 🧩 **Plugins/** - Server-Side Code
Documents C# plugins and custom workflow activities:
- Assembly purpose
- Plugin class definitions
- Message/stage registrations
- Business logic explanations

**Who maintains this**: .NET developers, Power Platform developers

---

### 🌐 **Power Pages Site/** - Portal
Documents the external-facing Power Pages portal:
- Lists, forms, templates
- Custom JavaScript and CSS
- Table permissions
- Web pages and navigation

**Who maintains this**: Portal developers, UX designers

---

### 🧬 **_schemas/** - Reusable Assets (Future)
Planned location for:
- JSON schemas
- Mermaid diagram templates
- Documentation templates
- Validation rules

---

## Rules for Adding New Documentation

### ✅ DO:
1. **Read the nearest README.md first** before adding new files
2. **Follow existing naming conventions** in that folder
3. **Add a README.md** if creating a new subfolder
4. **Use kebab-case** for folder names (e.g., `my-flow-name`)
5. **Use PascalCase** for table names matching Dataverse schema (e.g., `Case`, `Account`)
6. **Preserve existing structure** - do not reorganize without explicit approval
7. **Document assumptions** in README files if uncertain

### ❌ DON'T:
1. **Delete existing documentation** files without review
2. **Rename folders** unless normalizing to documented standards
3. **Create orphaned files** - every file should have a clear parent folder
4. **Duplicate content** - link to existing docs instead of copying
5. **Leave empty README files** - they must explain purpose AND structure

---

## AI Agent Guidelines

If you are an AI agent tasked with extending this documentation:

1. **This structure is authoritative** - treat it as the source of truth
2. **README.md files are structural memory** - always read them before acting
3. **Never break existing conventions** - follow the patterns you find
4. **When in doubt, ask** - add a comment or flag for human review rather than guessing
5. **Preserve all existing content** - migration and refactoring require explicit permission

---

## Documentation Standards

### Markdown Files
- Use clear headings (`#`, `##`, `###`)
- Include a "Purpose" or "Overview" section at the top
- Use code blocks with language tags (```javascript, ```sql, etc.)
- Add cross-references using relative links: `[Link](../Tables/Case/README.md)`

### Naming Conventions
- **Tables**: Match Dataverse schema name (e.g., `Case`, `Contact`, `revops_cumulusaccount`)
- **Flows**: Use kebab-case descriptive names (e.g., `case-escalation-notification`)
- **Plugins**: Use assembly names (e.g., `RevOps.EmailPlugins`)
- **Files**: Use lowercase with hyphens or underscores as appropriate

### File Organization
Every component should have:
- A parent folder (e.g., `Tables/Case/`)
- A README.md explaining its purpose
- Supporting files (schemas, diagrams, code samples)

---

## Quick Reference

| I want to... | Go to... |
|--------------|----------|
| Document a new table | `Tables/` → Create `TableName/` folder → Add README.md |
| Document a new flow | `Flows/` → Create `flow-name/` folder → Add README.md |
| Update Power Pages docs | `Power Pages Site/` → Find component type → Update .md file |
| Add a plugin | `Plugins/` → Create `AssemblyName/` folder → Add README.md |
| Find a template | `_schemas/` (future) or check existing README files |

---

## Maintenance

### Review Cycle
- **Quarterly**: Review for outdated documentation
- **After deployments**: Update affected component docs
- **After major changes**: Verify cross-references are valid

### Version Control
- This documentation is version-controlled alongside code
- Major structural changes require pull request review
- Breaking changes must update this README.md

---

## 📚 Documentation Index

### Quick Access
- **[QUICK-REFERENCE.md](./QUICK-REFERENCE.md)** - Fast navigation and common tasks
- **[DOCUMENTATION-SUMMARY.md](./DOCUMENTATION-SUMMARY.md)** - Complete statistics (683+ files)
- **[Tables/README.md](./Tables/README.md)** - Table documentation standards
- **[Flows/README.md](./Flows/README.md)** - Flow documentation standards

### Inventories
- **[_schemas/tables.json](./_schemas/tables.json)** - 53 tables metadata
- **[_schemas/flows.json](./_schemas/flows.json)** - 111 flows metadata

---

## Contact & Support

For questions about this documentation structure:
- **Technical Lead**: RevOps Team
- **Last Updated**: December 15, 2025
- **Structure Version**: 1.0
- **Status**: ✅ **COMPLETE** (53 tables, 111 flows, 683+ files documented)

---

**Remember**: Good documentation saves time. Invest the effort to keep this accurate and well-organized.