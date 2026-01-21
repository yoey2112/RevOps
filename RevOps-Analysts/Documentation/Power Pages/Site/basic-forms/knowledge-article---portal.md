# Knowledge Article - Portal

## Overview
This basic form allows portal users to view knowledge articles in read-only mode. It's designed for displaying knowledge base content to authenticated users without allowing modifications.

## Location
- **Path**: `.paportal\swdevportal\basic-forms\knowledge-article---portal\`
- **Form ID**: fc0d4a4f-b9f4-4c01-8cef-77f00c674cbd
- **Form Name**: Knowledge Article - Portal

## Configuration

### Entity Details
- **Entity Name**: `knowledgearticle` (Knowledge Article)
- **Form Name**: Knowledge Article - Portal
- **Mode**: ReadOnly (100000002)
- **Tab**: general

### Entity Permissions
- **Enabled**: Yes (`adx_entitypermissionsenabled: true`)

### Entity Source
- **Source Type**: Query String (756150001)
- **Record ID Query String Parameter**: id

### File Attachments
- **Enabled**: No (not configured for read-only mode)
- **Maximum Files**: 5 (default)
- **Storage Location**: Azure Blob Storage (756150000)

### Success Behavior
- **On Success**: Display Success Message (756150000)
- **Hide Form**: Yes
- **No Redirect**: Success behavior not applicable for read-only forms

### Security
- **CAPTCHA Required**: No
- **Show CAPTCHA for Authenticated Users**: No

## Custom Code

### JavaScript
**No custom JavaScript** - The form uses standard Power Pages functionality without additional client-side code.

### Liquid
No custom Liquid templates are associated with this form.

## Usage

### Portal User Experience
1. User navigates to a knowledge article URL (e.g., `/knowledge-article?id={article-guid}`)
2. Form loads the knowledge article in read-only mode
3. User can view:
   - Article title
   - Article content
   - Related metadata
   - Attachments (if any)
4. No editing or submission buttons are shown (read-only mode)

### URL Parameters
The form requires the following URL parameter:
- **id**: GUID of the knowledge article to display

Example URL: `https://portal.example.com/knowledge-article?id=12345678-1234-1234-1234-123456789abc`

### Typical Knowledge Article Fields Displayed
- **Title**: Article subject
- **Content**: Main article body
- **Article Number**: System-generated article identifier
- **Subject**: Article classification
- **Keywords**: Search keywords
- **Description**: Brief summary
- **Created Date**: When article was created
- **Modified Date**: Last modification timestamp
- **Published Status**: Whether article is published

## Related Components

### Dependencies
- Standard Power Pages form rendering
- Entity permissions on the Knowledge Article entity
- Knowledge article records in Dataverse

### Related Entities
- **knowledgearticle**: Primary entity
- **subject**: Article subject classification
- **category**: Article categorization

### Integration Points
This form is typically used in conjunction with:
- **Knowledge Base Search**: Users search for articles and click to view details
- **Case Forms**: May link to related knowledge articles
- **Support Portal**: Part of self-service knowledge base

## Change History

### Current Implementation
- Read-only mode for viewing knowledge articles
- Query string-based article loading
- Entity permissions enforcement
- No custom JavaScript or Liquid logic
- Standard knowledge article display

### Key Features
- **Read-Only Mode**: Prevents unauthorized editing
- **Query String Loading**: Flexible article display via URL parameter
- **Entity Permissions**: Respects security model for knowledge articles
- **Standard UX**: Uses out-of-the-box Power Pages form rendering
- **Knowledge Base Integration**: Designed for self-service support scenarios
