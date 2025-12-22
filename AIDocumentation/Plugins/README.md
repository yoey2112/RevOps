# Plugins

## Purpose

This folder contains documentation for **Dynamics 365 plugins** (custom server-side code) used in the RevOps system. Plugins execute business logic in response to Dataverse events (create, update, delete, retrieve, etc.) and run in the platform's sandbox environment.

---

## Folder Structure

Each plugin assembly gets its own folder following **PascalCase** naming conventions (matching C# class names):

```
Plugins/
├── README.md (this file)
├── EmailFromSetter/
│   ├── README.md
│   ├── plugin.logic.md
│   ├── EmailFromSetter.cs (source code)
│   └── registration.md
├── EmailToScrubber/
│   ├── README.md
│   ├── plugin.logic.md
│   ├── EmailToScrubber.cs
│   └── registration.md
├── UpdateSolutionCategoriesPlugin/
│   ├── README.md
│   ├── plugin.logic.md
│   ├── UpdateSolutionCategoriesPlugin.cs
│   └── registration.md
└── <PluginClassName>/
    ├── README.md
    ├── plugin.logic.md
    ├── <PluginClassName>.cs
    └── registration.md
```

---

## Naming Conventions

### Folder Names
- **Format**: `PascalCase` (matching the C# class name exactly)
- **Match**: Plugin class name without namespace
- **Examples**:
  - ✅ `EmailFromSetter` (class: `RevOps.EmailPlugins.EmailFromSetter`)
  - ✅ `UpdateSolutionCategoriesPlugin` (class: `RevOps.SolutionPlugins.UpdateSolutionCategoriesPlugin`)
  - ❌ `email-from-setter` (kebab-case not allowed for plugins)
  - ❌ `EmailFrom_Setter` (underscores not allowed)

### Plugin Categories (Common Patterns)
- **Validation**: Pre-validation of data before operation
- **Pre-Operation**: Modify data before database commit
- **Post-Operation**: Trigger additional logic after database commit
- **Custom Actions**: Handle custom API calls
- **Async Post-Operation**: Background processing after transaction completes

---

## Required Files per Plugin

Every plugin folder **MUST** contain:

### 1. `README.md` (Mandatory)
The overview and quick reference for the plugin.

**Template**:
```markdown
# <Plugin Class Name>

## Overview
[1-2 sentence description of what this plugin does]

## Business Purpose
[Why does this plugin exist? What business rule does it enforce?]

## Registration Details
- **Assembly**: [AssemblyName.dll, e.g., RevOps.EmailPlugins.dll]
- **Class**: [Full namespace path, e.g., RevOps.EmailPlugins.EmailFromSetter]
- **Isolation Mode**: [Sandbox/None]
- **Execution Mode**: [Synchronous/Asynchronous]

## Trigger Configuration
- **Message**: [Create/Update/Delete/Retrieve/Custom Action name]
- **Primary Entity**: [Table logical name, e.g., email, account]
- **Stage**: [Pre-Validation (10) / Pre-Operation (20) / Post-Operation (40)]
- **Execution Order**: [Number, e.g., 1]
- **Deployment**: [Server/Offline/Both]

## Filtering Attributes
[List of attributes that trigger the plugin, if applicable]
- `attribute1`
- `attribute2`

## High-Level Logic
[3-5 bullet points of what the plugin does]

## Error Handling
[How does this plugin handle exceptions? Throw InvalidPluginExecutionException?]

## Dependencies
- **Tables**: [List tables accessed by this plugin]
- **Services**: [IOrganizationService, ITracingService, custom services]
- **Other Plugins**: [Any plugins that must run before/after this one]
- **Environment Variables**: [Any configuration values from environment variables]

## Documentation Files
- `plugin.logic.md`: Detailed code walkthrough
- `<PluginClassName>.cs`: Source code (link to actual codebase location)
- `registration.md`: Step-by-step registration guide with screenshots

## Change History
- **YYYY-MM-DD**: [Change description]

## Known Issues / Limitations
[Any known issues, performance concerns, or limitations]

---

**Last Updated**: [Date]  
**Owner**: [Team/Person]
```

---

### 2. `plugin.logic.md` (Mandatory)
Detailed code walkthrough and business logic explanation.

**Purpose**:
- Explain the plugin's code step-by-step
- Document any FetchXML queries, early-bound classes, or complex logic
- Explain error handling and tracing
- Serve as a code review reference

**Template**:
```markdown
# Plugin Logic: <Plugin Name>

## Class Signature
**Namespace**: [e.g., RevOps.EmailPlugins]  
**Class Name**: [e.g., EmailFromSetter]  
**Base Class**: [IPlugin or PluginBase]

---

## Constructor
[If plugin has constructor logic, explain initialization]

```csharp
public EmailFromSetter() { }
```

---

## Execute Method

### 1. Context Retrieval
```csharp
IPluginExecutionContext context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
IOrganizationServiceFactory serviceFactory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
IOrganizationService service = serviceFactory.CreateOrganizationService(context.UserId);
ITracingService tracingService = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
```

**Purpose**: Retrieve plugin services for database access, logging, and context.

---

### 2. Input Validation
[Explain any early-exit conditions or validation]

```csharp
if (context.InputParameters.Contains("Target") && context.InputParameters["Target"] is Entity)
{
    Entity entity = (Entity)context.InputParameters["Target"];
    // Continue processing
}
else
{
    return; // Exit if no target entity
}
```

---

### 3. Business Logic

#### Step 1: [Action description]
[Explain what this section of code does]

```csharp
// Code snippet
```

**Purpose**: [Why this code exists]

#### Step 2: [Action description]
[Continue explaining each logical step]

---

### 4. Data Retrieval (if applicable)

#### FetchXML Query 1: [Description]
```xml
<fetch>
  <entity name="tablename">
    <attribute name="column1" />
    <filter>
      <condition attribute="column2" operator="eq" value="{0}" />
    </filter>
  </entity>
</fetch>
```

**Purpose**: [What this query retrieves]

---

### 5. Error Handling
[Explain try-catch blocks and exception handling]

```csharp
try
{
    // Business logic
}
catch (FaultException<OrganizationServiceFault> ex)
{
    tracingService.Trace("Error: {0}", ex.ToString());
    throw new InvalidPluginExecutionException("An error occurred in EmailFromSetter plugin.", ex);
}
```

**Strategy**: [How errors are logged and surfaced to users]

---

## Tracing & Debugging
[Explain tracing strategy]

```csharp
tracingService.Trace("EmailFromSetter: Starting execution");
tracingService.Trace("Processing email with ID: {0}", emailId);
```

**Best Practice**: Use verbose tracing for production debugging without debugger access.

---

## Performance Considerations
- [Any database query optimizations]
- [Batch operations or pagination]
- [Avoiding infinite loops]

---

**Last Updated**: [Date]
```

---

### 3. `<PluginClassName>.cs` (Mandatory)
The actual C# source code file.

**Location**:
- Store in plugin project folder (e.g., `c:\RevOps\RevOps-Analysts\Plugins\RevOps.EmailPlugins\RevOps.EmailPlugins\EmailFromSetter.cs`)
- **Link** to this file from the documentation folder (do NOT duplicate)

**In Documentation Folder**:
- Either create a **symbolic link** to the actual source file
- OR create a **reference file** with a link to the codebase location

**Reference File Template**:
```markdown
# EmailFromSetter.cs

**Source Location**: `c:\RevOps\RevOps-Analysts\Plugins\RevOps.EmailPlugins\RevOps.EmailPlugins\EmailFromSetter.cs`

**Assembly**: RevOps.EmailPlugins.dll

**Namespace**: RevOps.EmailPlugins

**Class**: EmailFromSetter

---

For detailed code walkthrough, see `plugin.logic.md`.

For source code, navigate to the file path above.
```

---

### 4. `registration.md` (Mandatory)
Step-by-step guide for registering the plugin using the Plugin Registration Tool.

**Template**:
```markdown
# Plugin Registration: <Plugin Name>

## Prerequisites
- Plugin Registration Tool (PRT) installed
- Compiled plugin assembly (.dll file)
- Strong name key (.snk) used to sign assembly
- System Administrator or System Customizer role in target environment

---

## Step 1: Build and Sign Assembly

### Build Configuration
- **Configuration**: Release (not Debug)
- **Platform**: Any CPU
- **Strong Name Key**: `RevOpsKey.snk` (or applicable .snk file)

### Build Command
```powershell
msbuild RevOps.EmailPlugins.csproj /p:Configuration=Release
```

**Output**: `bin\Release\RevOps.EmailPlugins.dll`

---

## Step 2: Register Assembly in Plugin Registration Tool

1. Open **Plugin Registration Tool**
2. Click **Create New Connection**
3. Select deployment type (Office 365, IFD, On-Premises)
4. Authenticate to target environment
5. Click **Register** → **Register New Assembly**

### Assembly Registration Settings
- **Step 1: Select Assembly**:
  - Browse to `bin\Release\RevOps.EmailPlugins.dll`
- **Step 2: Isolation Mode**: 
  - ✅ **Sandbox** (recommended for cloud)
  - ⬜ None (only for on-premises with full trust)
- **Step 3: Location**: 
  - ✅ **Database** (standard for all deployments)
  - ⬜ Disk (legacy, not recommended)

Click **Register Selected Plugins**.

---

## Step 3: Register Plugin Step

1. Expand the registered assembly in PRT
2. Right-click the plugin class (e.g., `EmailFromSetter`)
3. Select **Register New Step**

### Step Configuration
| Setting | Value |
|---------|-------|
| **Message** | Create / Update / Delete / etc. |
| **Primary Entity** | email / account / etc. |
| **Secondary Entity** | (leave blank) |
| **Filtering Attributes** | attribute1, attribute2 (comma-separated) |
| **Event Pipeline Stage** | Pre-Validation (10) / Pre-Operation (20) / Post-Operation (40) |
| **Execution Mode** | Synchronous / Asynchronous |
| **Deployment** | Server / Offline / Both |
| **Execution Order** | 1 (or specific order) |
| **Description** | [Brief description of what this step does] |

Click **Register New Step**.

---

## Step 4: Verify Registration

1. In PRT, locate the plugin step under the plugin class
2. Verify all settings match requirements
3. Test in a **development/sandbox environment first**

### Testing Checklist
- [ ] Plugin triggers on expected event (create/update/delete)
- [ ] Plugin executes without errors
- [ ] Plugin produces expected results
- [ ] No performance degradation observed
- [ ] Error handling works as expected (test with invalid data)

---

## Step 5: Deploy to Production

### Pre-Deployment Checklist
- [ ] Tested in DEV environment
- [ ] Tested in UAT/Staging environment
- [ ] Code reviewed and approved
- [ ] Change request approved (if required)
- [ ] Rollback plan prepared

### Deployment Steps
1. Export solution containing plugin from DEV
2. Import solution to PROD
3. Activate solution
4. Verify plugin step is active
5. Monitor system for 24-48 hours for errors

---

## Rollback Procedure

If plugin causes issues in production:

1. **Disable Plugin Step**: 
   - In PRT, right-click the step → **Disable**
2. **Unregister Step** (if needed):
   - Right-click → **Unregister**
3. **Revert to Previous Assembly Version**:
   - Update assembly with previous version
4. **Notify Stakeholders**: Document incident and root cause

---

## Troubleshooting

### Common Issues

**Issue**: Plugin does not trigger
- **Cause**: Filtering attributes too restrictive or message type incorrect
- **Fix**: Verify registration settings match trigger conditions

**Issue**: "Plugin execution failed" error
- **Cause**: Unhandled exception in plugin code
- **Fix**: Check Plugin Trace Logs in Dynamics or Application Insights

**Issue**: Performance degradation
- **Cause**: Plugin runs synchronously and queries large datasets
- **Fix**: Switch to asynchronous execution or optimize queries

---

**Last Updated**: [Date]
```

---

## Best Practices for Plugin Documentation

### When Creating New Plugin Documentation
1. ✅ **Always** create the folder using `PascalCase` matching the class name
2. ✅ **Always** create all 4 mandatory files (README, logic, source link, registration)
3. ✅ Document registration settings in detail (message, entity, stage, mode)
4. ✅ Include business context (why the plugin exists)
5. ✅ Explain error handling and tracing strategy
6. ✅ Add screenshots to `registration.md` for complex steps
7. ✅ Link to actual source code location (do not duplicate .cs files)

### When Updating Existing Plugin Documentation
1. ✅ Update `plugin.logic.md` if code changes
2. ✅ Update `README.md` if registration settings change (message, entity, etc.)
3. ✅ Add change history entry to `README.md` with date and description
4. ✅ Review dependencies and update if new tables/services are involved
5. ✅ Update `registration.md` if deployment process changes

### When Analyzing Plugins
1. ✅ Start with `README.md` for high-level understanding
2. ✅ Read `plugin.logic.md` for detailed code walkthrough
3. ✅ Review actual source code (`.cs` file) for implementation details
4. ✅ Check `registration.md` to understand deployment and configuration

---

## AI Agent Guidelines

When working with plugins in this folder:

### ✅ DO
- Create new plugin folders using `PascalCase` matching C# class names
- Generate all 4 mandatory files when documenting a new plugin
- Link to actual source code location (do NOT duplicate .cs files in Documentation folder)
- Document message, entity, stage, and execution mode clearly
- Explain business logic and error handling in detail
- Update change history when plugins are modified
- Link plugins to related Tables, Flows, and Power Pages components

### ❌ DO NOT
- Delete existing plugin folders (even if renamed)
- Skip mandatory files (all 4 must exist)
- Use kebab-case or snake_case for folder names (plugins use PascalCase)
- Duplicate .cs source code files (link to actual codebase instead)
- Document plugins without registration details
- Forget to explain filtering attributes and execution order

---

## Known Plugins in This Repository

### Email Plugins (RevOps.EmailPlugins.dll)
1. **EmailFromSetter**: Sets the "from" address on outgoing emails based on business rules
2. **EmailToScrubber**: Validates and sanitizes recipient addresses before sending

### Solution Plugins (RevOps.SolutionPlugins.dll)
3. **UpdateSolutionCategoriesPlugin**: Automatically categorizes solutions based on components

*(Update this list as new plugins are documented)*

---

## Relationship to Source Code

### Actual Plugin Projects
Plugin source code is located in:
- `c:\RevOps\RevOps-Analysts\Plugins\RevOps.EmailPlugins\`
- `c:\RevOps\RevOps-Analysts\Plugins\RevOps.SolutionPlugins\`

### Documentation Folder
This folder (`Documentation/Plugins/`) contains **documentation only**, not source code.

### Linking Strategy
- Documentation files **reference** source code by file path
- Use symbolic links OR reference markdown files
- **Never duplicate** .cs files in Documentation folder

---

## TODO / Future Enhancements

- [ ] Document `EmailFromSetter` plugin
- [ ] Document `EmailToScrubber` plugin
- [ ] Document `UpdateSolutionCategoriesPlugin` plugin
- [ ] Add screenshots to `registration.md` files
- [ ] Create plugin dependency graph (which plugins run in sequence)
- [ ] Document custom actions (if any)
- [ ] Add unit test documentation
- [ ] Create troubleshooting runbook for common plugin errors

---

**Last Updated**: December 15, 2025  
**Maintained By**: RevOps Development Team