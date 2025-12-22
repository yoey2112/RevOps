# Tables - Dataverse Table Documentation

## Purpose

This folder contains comprehensive documentation for all **custom** and **heavily customized Dataverse tables** in the RevOps environment. Each table's business purpose, technical implementation, and integration points are documented here.

---

## Structure Rules

Each table MUST have its own folder named exactly as it appears in Dataverse:

```
Tables/
└── <TableName>/
    ├── README.md              ← Required: Table overview and purpose
    ├── Columns.md             ← Optional: Detailed column documentation
    ├── Relationships.md       ← Optional: Relationship documentation
    ├── Forms/                 ← Optional: Form-specific documentation
    │   └── <FormName>.md
    └── Web_resources/         ← Required if form scripts exist
        └── <script-name>.js   ← JavaScript files with inline comments
```

---

## Naming Conventions

### Table Folder Names
- **Custom tables**: Use schema name (e.g., `revops_cumulusaccount`)
- **Standard tables**: Use display name (e.g., `Case`, `Account`, `Contact`)
- **Match exactly** to avoid confusion

### Files Within Table Folders
- `README.md` - **Required** for every table
- `Columns.md` - Optional, use if many custom columns need detailed explanation
- `Relationships.md` - Optional, document complex relationship logic
- `Forms/*.md` - One file per form if form-specific documentation is needed
- `Web_resources/*.js` - Actual JavaScript files (not .md wrappers)

---

## What Belongs Here

### ✅ Document These Tables:
- All **custom tables** (prefix: `revops_`, `new_`, etc.)
- **Standard tables** with heavy customization (Case, Account, Contact, etc.)
- Tables with:
  - Custom business logic
  - Form scripts
  - Complex relationships
  - Important to business operations

### ❌ Don't Document:
- Unmodified standard tables (unless context is needed)
- System tables (unless touched by customizations)
- Temporary/test tables

---

## README.md Template for Tables

Every table's `README.md` must include:

```markdown
# <Table Display Name>

## Business Purpose
Why does this table exist? What problem does it solve?

## Key Use Cases
- Use case 1
- Use case 2

## Primary Relationships
- Related to: <Table> via <Relationship>
- Lookup from: <Table>

## Automation Touchpoints
- **Flows**: List flows that trigger on this table
- **Plugins**: List plugins registered on this table
- **Business Rules**: Describe any business rules

## Forms
- Main Form: <Form Name> - Purpose
- Quick Create: <Form Name> - Purpose

## Security
- Who can access this table?
- Any special table permissions (if Power Pages)?

## Reporting Considerations
- Used in which reports/dashboards?
- Key metrics tracked?

## Change History
- 2025-12-15: Initial documentation
```

---

## Web Resources Rules

### Where JavaScript Files Go

**Form-specific scripts** (only used on ONE table's forms):
```
Tables/<TableName>/Web_resources/
└── revops_<feature>.js
```

**Shared/global scripts** (used across MULTIPLE tables):
- Create a `_shared/` folder at `Tables/_shared/Web_resources/`
- Document which tables/forms use each shared script

### JavaScript File Standards
1. **Keep actual .js files** - do not convert to .md unless documenting separately
2. **Add inline comments** explaining complex logic
3. **Header comment block** with:
   - Purpose
   - Author/Date
   - Tables/Forms where used
   - Dependencies

Example:
```javascript
/**
 * revops_p2ptransfercreate.js
 * 
 * Purpose: Manages P2P transfer case creation and auto-population
 * Used on: Case form (P2P Transfer)
 * Dependencies: None
 * 
 * Last Updated: 2025-12-15
 */
```

---

## Current Tables Documented

| Table | Folder | Status | Notes |
|-------|--------|--------|-------|
| Case (incident) | `Case/` | ✅ Partial | Has web resources, needs README.md |

---

## How to Add a New Table

1. **Create folder**: `Tables/<TableName>/`
2. **Copy template**: Use the README.md template above
3. **Fill in details**: Business purpose, relationships, automation
4. **Add web resources**: If the table has form scripts, add them to `Web_resources/`
5. **Document forms**: If forms have complex logic, create `Forms/<FormName>.md`
6. **Update this README**: Add table to "Current Tables Documented" section

---

## Migration Notes

### Existing Structure
- `Tables/Case/` already exists with `Web_resources/` and empty `Forms/`
- Need to create `Tables/Case/README.md`

### Future Additions
- Consider `Tables/Account/` for Cumulus Account relationships
- Consider `Tables/Contact/` if portal contact logic needs documentation
- Consider `Tables/revops_cumulusaccount/` for custom Cumulus table

---

## AI Agent Instructions

If you are an AI agent adding table documentation:

1. **Read this file first** before creating any new folders
2. **Follow the structure exactly** - do not invent new patterns
3. **Create README.md** for every new table folder
4. **Never delete existing web resources** - they are source code
5. **Ask before moving files** between tables or to `_shared/`

---

## Maintenance

- **Review**: Quarterly or after significant table schema changes
- **Update**: When new columns, relationships, or forms are added
- **Archive**: Move deprecated table docs to `Tables/_archived/` (don't delete)

---

**Last Updated**: December 15, 2025  
**Maintained By**: RevOps Development Team