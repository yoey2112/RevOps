# Quick Reference Guide

**Generated**: December 15, 2025  
**Purpose**: Fast navigation to key documentation

---

## 📊 Documentation Stats

| Category | Count | Files per Item | Total Files |
|----------|-------|----------------|-------------|
| **Tables** | 53 | 3 | 159 |
| **Flows** | 111 | 4 | 444 |
| **Power Pages** | - | - | 80 |
| **Total** | 164 | - | **683** |

---

## 🗂️ Folder Structure Quick Reference

```
Documentation/
├── Tables/          → 53 tables (PascalCase folders)
├── Flows/           → 111 flows (kebab-case folders)
├── Power Pages Site/→ Web portal docs
├── Plugins/         → Server-side code
├── _schemas/        → tables.json, flows.json
├── _scripts/        → Automation scripts
└── _Exports/        → Solution export sources
```

---

## 🔍 How to Find...

### A Specific Table
1. Check `_schemas/tables.json` for folder name
2. Navigate to `Tables/{FolderName}/`
3. Start with `README.md`

**Example**: Find "Transfer" table
```
Tables/Transfer/
├── README.md           ← Start here
├── Columns.md          ← All 64 columns
└── Relationships.md    ← Lookup fields
```

### A Specific Flow
1. Check `_schemas/flows.json` for folder name
2. Navigate to `Flows/{folder-name}/`
3. Start with `README.md`

**Example**: Find ISO3166 country mapping flow
```
Flows/iso3166cumulusaccounttoaccount-manual/
├── README.md           ← Purpose & trigger
├── flow.logic.md       ← Action details
├── flow.schema.json    ← Full definition
└── diagram.mmd         ← Visual diagram
```

### Custom Code on Forms
Look in table folder:
```
Tables/{TableName}/Web_resources/
```

**Example**: P2P Transfer scripts
```
Tables/Case/Web_resources/
├── revops_p2ptransfercreate.js       ← Region auto-fill
└── revops_p2p_competitor_filter.js   ← Competitor filtering
```

---

## 📋 Common Tasks

### Regenerate All Documentation
```powershell
cd Documentation\_scripts

# All tables (53 tables)
.\Generate-AllTableDocs.ps1

# All flows (111 flows)
.\Generate-FlowDocs.ps1

# Specific table (example: Case)
.\Generate-CaseColumns.ps1
.\Generate-CaseRelationships.ps1
```

### Find What Flows Touch a Table
```powershell
# Search flow schema files
Get-ChildItem "Flows\*\flow.schema.json" -Recurse | 
  Select-String "revops_transfer" |
  ForEach-Object { Split-Path (Split-Path $_.Path) -Leaf }
```

### Find All Tables with JavaScript
```powershell
Get-ChildItem "Tables\*\Web_resources\*.js" -Recurse | 
  Select-Object Directory, Name
```

---

## 🎯 Critical Documentation

### High-Priority Tables
1. **Case** - Support tickets, P2P transfers (119 columns)
2. **Transfer** - P2P technical transfers (64 columns)
3. **Cumulus Account** - Billing integration (66 columns)
4. **Account** - Master customer records
5. **Contact** - People records

### Key Flows
1. **iso3166-cumulus-account-to-account** - Region mapping
2. **account-created-in-cumulus** - Billing sync
3. **p2p-automation** - Transfer automation
4. **enrich-*** - Data enrichment (Account/Contact/Lead)
5. **form-submission-utm-values** - Marketing attribution

### Power Pages Critical Components
- **P2P Transfer Forms**: `Power Pages Site/basic-forms/case---create-p2p-from-portal.md`
- **Custom CSS**: `Power Pages Site/web-files/custom.css.md`
- **API Endpoints**: `Power Pages Site/web-templates/api-*.md`

---

## 🏗️ Naming Conventions (IMPORTANT!)

| Type | Convention | Example |
|------|------------|---------|
| Table Folders | PascalCase | `CumulusAccount/` |
| Flow Folders | kebab-case | `account-created-in-cumulus/` |
| Files | lowercase-hyphen | `flow.logic.md` |
| Custom Tables | `revops_` prefix | `revops_transfer` |

**Note**: Some legacy flows have mixed naming (spaces, capitals). New flows should use kebab-case.

---

## 🔧 Automation Scripts

Located in `_scripts/`:

| Script | Purpose | Usage |
|--------|---------|-------|
| `Parse-TableExport.ps1` | Extract table metadata | Creates `tables.json` |
| `Generate-AllTableDocs.ps1` | Bulk table docs | All 53 tables |
| `Generate-CaseColumns.ps1` | Case columns only | Single table |
| `Generate-CaseRelationships.ps1` | Case relationships | Single table |
| `Generate-FlowDocs.ps1` | Bulk flow docs | All 111 flows |

---

## 📐 File Templates

### Table Documentation (3 files)
```
Tables/{TableName}/
├── README.md          # Business purpose, relationships, automation
├── Columns.md         # All columns with types & descriptions
└── Relationships.md   # Lookups FROM and TO this table
```

### Flow Documentation (4 files)
```
Flows/{flow-name}/
├── README.md          # Purpose, trigger, dependencies
├── flow.logic.md      # Action-by-action breakdown
├── flow.schema.json   # Complete flow definition (export)
└── diagram.mmd        # Mermaid diagram (or .drawio)
```

---

## 🚀 Quick Wins

### Most Complex Tables (by column count)
1. Case: 119 columns
2. Onboarding Call: 71 columns
3. Demo: 67 columns
4. Cumulus Account: 66 columns
5. Transfer: 64 columns

### Flows with Most Actions
*Check `_schemas/flows.json` for `ActionCount`*

### Tables with JavaScript (Form Scripts)
- Case
- Account
- Contact
- Lead
- Opportunity
- Transfer
- Pricing Request
- Email
- Churn
- UTM Link

---

## 📞 Support

**Questions?** Check `Documentation/README.md` for governance rules.

**Updates?** Run automation scripts in `_scripts/`.

**Issues?** All AI-generated content is marked with:
```markdown
<!-- AI:BEGIN AUTO -->
Auto-generated content
<!-- AI:END AUTO -->
```

---

**Maintained By**: RevOps Development Team  
**Last Updated**: December 15, 2025
