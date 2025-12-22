# Web Templates Documentation Summary

## Overview
This document provides a comprehensive summary of all documented web templates in the Power Pages site, highlighting their complexity, functionality, and key features.

## Documentation Location
`c:\RevOps\RevOps-Analysts\Documentation\Power Pages\Site\web-templates\`

---

## High-Complexity Templates (Custom Logic & Integrations)

### 1. API Cumulus Orgs ⭐⭐⭐⭐⭐
**File:** `api-cumulus-orgs.md`

**Complexity Level:** Very High

**Key Features:**
- **FetchXML Query** with table permissions security
- **JSON API endpoint** (no layout, returns application/json)
- **GUID validation** with regex pattern matching
- **Custom entity integration** (revops_cumulusorganization)
- **Error handling** with structured JSON responses
- **Security:** Requires table permissions and web role assignment

**Use Case:** AJAX/fetch calls to populate organization dropdowns based on parent Cumulus Account

**Notable Code:**
- Validates accountid parameter before querying
- Returns up to 500 organizations
- Uses `no-lock='true'` for read consistency

---

### 2. Header ⭐⭐⭐⭐⭐
**File:** `header.md`

**Complexity Level:** Very High

**Key Features:**
- **Multi-level navigation** (2-level dropdown support)
- **Language switching** with locale detection
- **Search integration** with filter dropdown
- **User authentication** state management
- **Quick access bar** (sticky navigation with bilingual support)
- **Chat widget integration** (EN/FR variants)
- **JavaScript functionality:**
  - Ticket options menu toggle
  - Chat modal trigger
  - Navbar height management
  - Navigation menu reordering
  - IE compatibility handling

**Use Case:** Site-wide header navigation on every page

**Notable Code:**
- 200+ lines of complex Liquid logic
- Extensive CSS for custom styling
- Dynamic quick-access bar with authenticated/unauthenticated variants
- Microsoft Omnichannel chat integration

---

### 3. KB Category Widget ⭐⭐⭐⭐
**File:** `kbcategorywidget.md`

**Complexity Level:** High

**Key Features:**
- **Hierarchical category structure** with parent-child relationships
- **Two FetchXML queries** (articles and categories)
- **Aggregate queries** for performance
- **Custom entity fields:**
  - `revops_category`
  - `revops_istoplevelcategory`
  - `revops_isinternal`
- **Duplicate prevention logic**
- **Conditional rendering** (filtered vs. full hierarchy)
- **Article count badges**
- **Empty state handling**

**Use Case:** Display knowledge base categories with article previews (top 5 per category)

**Notable Code:**
- Complex category filtering and grouping
- Links to category detail pages with query parameters
- Responsive 2-column layout

---

### 4. KB Category Widget Top 5 ⭐⭐⭐⭐
**File:** `kbcategorywidgettop5.md`

**Complexity Level:** High

**Key Features:**
- **Two FetchXML queries:**
  - Popular articles (by view count)
  - New articles (by creation date)
- **Custom CSS styling** with Google Fonts (Montserrat)
- **Card-based layout** with hover effects
- **Light blue themed cards** (#dff0ff)
- **Custom button styling** (brand colors)

**Use Case:** Homepage widget showing Popular and New articles

**Notable Code:**
- Extensive CSS (100+ lines)
- Custom brand styling (#ed573c Sherweb orange)
- Badge visibility hidden via CSS

---

### 5. Faceted Search - Results Template ⭐⭐⭐⭐
**File:** `faceted-search---results-template.md`

**Complexity Level:** High

**Key Features:**
- **Handlebars.js templating** for client-side rendering
- **Custom pagination styling** (Montserrat font)
- **Parent article references**
- **Clear filters functionality**
- **Empty state handling**
- **Related notes feature** (currently disabled)
- **Liquid-Handlebars bridge** for variable escaping

**Use Case:** Display search results with metadata and formatting

**Notable Code:**
- Fixed-width icon holder (40px)
- Custom pagination with connected borders
- Result count display ("Results X-Y of Z")

---

### 6. Faceted Search - Facets Template ⭐⭐⭐⭐⭐
**File:** `faceted-search---facets-template.md`

**Complexity Level:** Very High

**Key Features:**
- **Four facet types:**
  - Record Type (multi-select listbox)
  - Modified Date (single-select radio)
  - Rating (star-based filtering)
  - Product (multi-select checkbox)
- **Comprehensive ARIA accessibility** (roles, labels, states)
- **Show more/less expandable lists**
- **Star rating visualization** (filled/empty stars)
- **Hit counts** per facet option
- **Currently hidden** (d-none class)

**Use Case:** Search filter sidebar (currently disabled)

**Notable Code:**
- 200+ lines of Handlebars templates
- Complex accessibility implementation
- Keyboard navigation support

---

### 7. Article ⭐⭐⭐⭐
**File:** `article.md`

**Complexity Level:** High

**Key Features:**
- **Article ID parsing** from URL slug
- **FetchXML query** with multiple filters
- **Client-side date formatting** (IIFE implementation)
- **Locale-aware formatting**
- **Error handling** with console logging
- **Responsive container** (80% max-width)
- **Metadata display** (created/modified dates)

**Use Case:** Knowledge base article detail page

**Notable Code:**
- Configurable date formatting function
- Article version filtering (primary, published, external)
- Clean separation of concerns (Liquid + JS)

---

## Medium-Complexity Templates (Integration & Logic)

### 8. Faceted Search - Main Template ⭐⭐⭐
**File:** `faceted-search---main-template.md`

**Complexity Level:** Medium

**Key Features:**
- **Container/orchestrator template**
- **Facet order definition** (4 facet types)
- **Handlebars body container template**
- **Loading spinner** with FontAwesome
- **Responsive layout** (with/without facets)
- **Includes sub-templates:**
  - Paging Template
  - Sort Template
  - Facets Template
  - Results Template

**Use Case:** Main search page container

---

### 9. Chat Widget - EN ⭐⭐⭐
**File:** `chat-widget---en.md`

**Complexity Level:** Medium

**Key Features:**
- **Microsoft Omnichannel integration**
- **Custom button styling** (60x60px)
- **FontAwesome icon replacement**
- **Brand color customization** (#ed573c)
- **Montserrat font** integration
- **1-second delay** for icon replacement

**Use Case:** English language chat widget

**Configuration:**
- App ID: `12495120-70a5-49bb-908d-3f9eb30f72f4`
- Org ID: `5bd79da4-af21-ef11-8407-0022486dacf1`

---

### 10. Chat Widget - FR ⭐⭐⭐
**File:** `chat-widget---fr.md`

**Complexity Level:** Medium

**Key Features:**
- Identical to EN version with different configuration
- Separate Omnichannel organization for French routing

**Use Case:** French language chat widget

**Configuration:**
- App ID: `2b027e25-455d-4931-9819-901d480291d4`
- Org ID: `536d3c28-6123-ef11-8406-6045bd5bd4f3`

**Note:** Header text "Chat with us" is English in both versions

---

### 11. Footer ⭐⭐⭐
**File:** `footer.md`

**Complexity Level:** Medium

**Key Features:**
- **Dynamic accessibility links** based on browser language
- **JavaScript language detection** (French, Italian)
- **Editable content snippet** integration
- **Print-friendly** (d-print-none)
- **Responsive layout** (9/3 column split)

**Use Case:** Site-wide footer

**Supported Languages:**
- French: Microsoft accessibility statement
- Italian: Microsoft accessibility statement
- Other: Removes accessibility container

---

### 12. Power Virtual Agents ⭐⭐⭐
**File:** `power-virtual-agents.md`

**Complexity Level:** Medium

**Key Features:**
- **Dynamic SDK loading**
- **Bot configuration from Dataverse** (adx_botconsumer entity)
- **JSON configuration** support
- **Customizable styling** (header, canvas, widget)
- **Environment integration**
- **Language support**

**Use Case:** Embed Power Virtual Agents chatbot

**Configuration:**
- Fixed dimensions: 320x480px
- Client: "msportals"
- Version: "v1"

---

### 13. Search ⭐⭐⭐
**File:** `search.md`

**Complexity Level:** Medium

**Key Features:**
- **Optional filter dropdown** (entity type filtering)
- **Bootstrap 5 integration**
- **Unique form ID generation**
- **Pre-populated query** support
- **Accessible form controls** (ARIA, hidden labels)
- **Flexbox layout** with gap utilities

**Use Case:** Search form in header and search page

**Parameters:**
- `q` - Search query
- `logicalNames` - Entity filter

---

## Low-Complexity Templates (Simple Display)

### 14. Default Studio Template ⭐
**File:** `default-studio-template.md`

**Complexity Level:** Low

**Key Features:**
- **Minimal structure** (system template)
- **Editable content area** with Liquid support
- **Skip-to-content target** (#mainContent)
- **ARIA landmark** (role="main")

**Use Case:** Default page template in Power Pages Studio

**Warning:** "Please do not modify" - System template

---

### 15. Breadcrumbs ⭐
**File:** `breadcrumbs.md`

**Complexity Level:** Low

**Key Features:**
- **Hierarchical navigation** from page.breadcrumbs
- **Title truncation** (24 characters)
- **HTML encoding** for security
- **Bootstrap breadcrumb styling**
- **Customizable active title**

**Use Case:** Page navigation breadcrumb trail

---

### 16. Languages Dropdown ⭐
**File:** `languages-dropdown.md`

**Complexity Level:** Low

**Key Features:**
- **Alphabetical ordering** by language name
- **URL substitution** for language switching
- **Accessibility roles** (menu/menuitem)
- **Data attributes** for language code

**Use Case:** Language selector in header

---

## Template Categories

### Navigation & Layout
- Header (Very High)
- Footer (Medium)
- Breadcrumbs (Low)
- Default Studio Template (Low)
- Languages Dropdown (Low)

### Search & Discovery
- Search (Medium)
- Faceted Search - Main Template (Medium)
- Faceted Search - Results Template (High)
- Faceted Search - Facets Template (Very High)

### Knowledge Base
- KB Category Widget (High)
- KB Category Widget Top 5 (High)
- Article (High)

### Chat & Support
- Chat Widget - EN (Medium)
- Chat Widget - FR (Medium)
- Power Virtual Agents (Medium)

### API & Integration
- API Cumulus Orgs (Very High)

---

## Key Technologies Used

### Liquid Templating
- All templates use Liquid
- Complex filtering and data manipulation
- Editable content areas
- FetchXML integration

### JavaScript
- **Header:** Navigation, chat integration, IE compatibility
- **Article:** Date formatting (IIFE)
- **Footer:** Dynamic accessibility links
- **Chat Widgets:** Icon replacement, SDK customization
- **Power Virtual Agents:** Dynamic SDK loading

### FetchXML
- **API Cumulus Orgs:** Organization query
- **KB Category Widget:** Articles and categories (2 queries)
- **KB Category Widget Top 5:** Popular and new articles (2 queries)
- **Article:** Single article retrieval

### Handlebars.js
- **Faceted Search templates:** Client-side rendering
- Results, facets, pagination, sorting

### External Integrations
- **Microsoft Omnichannel:** Chat widgets
- **Power Virtual Agents:** Chatbot embedding
- **Google Fonts:** Montserrat typography
- **FontAwesome:** Icons (regular and light)

### CSS Frameworks
- **Bootstrap 5:** Layout, components, utilities
- **Custom CSS:** Branding, specialized styling

---

## Security Features

### Table Permissions
- **API Cumulus Orgs:** Read permission on revops_cumulusorganization

### Input Validation
- **API Cumulus Orgs:** GUID regex validation
- **Article:** Article ID parsing and sanitization

### HTML Encoding
- All user-facing output escaped with `| h` or `| escape` filters
- XSS prevention

### Authentication
- **Header:** User state management (authenticated/unauthenticated)
- **API endpoints:** Require appropriate permissions

---

## Accessibility Features

### ARIA Implementation
- **Faceted Search - Facets:** Comprehensive ARIA (roles, labels, states)
- **Search:** Form labels and roles
- **Header:** Navigation landmarks, skip-to-content
- **Breadcrumbs:** Proper list semantics

### Keyboard Navigation
- **Faceted Search:** TabIndex management
- **Header:** Dropdown keyboard access
- **Search:** Full keyboard support

### Screen Reader Support
- Hidden labels (`.visually-hidden`)
- ARIA labels and descriptions
- Semantic HTML structure

---

## Performance Considerations

### Query Optimization
- **API Cumulus Orgs:** `no-lock='true'`, top 500 limit
- **KB widgets:** Aggregate queries, limited results
- **Article:** Single record fetch, top 1

### Asset Loading
- **Chat Widgets:** Async script loading
- **Power Virtual Agents:** Dynamic SDK injection
- **Fonts:** Google Fonts with display=swap

### Caching
- Static content in footers/headers
- Language dropdowns pre-rendered

---

## Internationalization (i18n)

### Bilingual Support
- **Header:** EN/FR quick access bars
- **Chat Widgets:** Separate EN/FR configurations
- **Footer:** French and Italian accessibility links
- **Languages Dropdown:** Multi-language support

### Locale Handling
- **Article:** Date formatting with locale support
- **Power Virtual Agents:** Accessibility language parameter
- **Search:** Localized resource strings

---

## Recommendations for Future Enhancements

### High Priority
1. **Enable faceted search** - Remove `d-none` classes and test functionality
2. **Localize chat widget** - Change "Chat with us" to "Chattez avec nous" in FR version
3. **API security hardening** - Add rate limiting to API Cumulus Orgs endpoint
4. **Schema.org markup** - Add BreadcrumbList schema to Breadcrumbs template

### Medium Priority
5. **Responsive dimensions** - Make PVA chat widget responsive
6. **Article enhancements** - Add related articles, social sharing, TOC
7. **Performance monitoring** - Add analytics to track template performance
8. **Error handling** - Improve error messages and fallback UI

### Low Priority
9. **Configuration flexibility** - Make more styling options configurable
10. **Documentation expansion** - Document remaining templates (pagination, sort, etc.)

---

## Template Complexity Legend

- ⭐ - Low Complexity: Simple display logic, minimal customization
- ⭐⭐⭐ - Medium Complexity: Integration, moderate logic, styling
- ⭐⭐⭐⭐ - High Complexity: Multiple queries, advanced features, extensive logic
- ⭐⭐⭐⭐⭐ - Very High Complexity: Complex integrations, API endpoints, comprehensive functionality

---

## Documentation Statistics

- **Total Templates Documented:** 16
- **Very High Complexity:** 3 (API Cumulus Orgs, Header, Faceted Search - Facets)
- **High Complexity:** 5 (KB widgets, Article, Search Results)
- **Medium Complexity:** 5 (Search, Chat widgets, Footer, PVA)
- **Low Complexity:** 3 (Default Studio, Breadcrumbs, Languages Dropdown)

- **Templates with FetchXML:** 4
- **Templates with JavaScript:** 6
- **Templates with Handlebars:** 3
- **Templates with External Integrations:** 3

---

## Quick Reference Table

| Template | Complexity | Primary Function | Key Technology |
|----------|-----------|------------------|----------------|
| API Cumulus Orgs | ⭐⭐⭐⭐⭐ | JSON API endpoint | FetchXML, Liquid |
| Header | ⭐⭐⭐⭐⭐ | Site navigation | Liquid, JavaScript |
| Faceted Search - Facets | ⭐⭐⭐⭐⭐ | Search filters | Handlebars, ARIA |
| KB Category Widget | ⭐⭐⭐⭐ | Category display | FetchXML, Liquid |
| KB Category Widget Top 5 | ⭐⭐⭐⭐ | Top articles | FetchXML, Custom CSS |
| Faceted Search - Results | ⭐⭐⭐⭐ | Search results | Handlebars, CSS |
| Article | ⭐⭐⭐⭐ | Article display | FetchXML, JavaScript |
| Faceted Search - Main | ⭐⭐⭐ | Search container | Handlebars, Liquid |
| Chat Widget - EN | ⭐⭐⭐ | Chat integration | Omnichannel, JS |
| Chat Widget - FR | ⭐⭐⭐ | Chat integration | Omnichannel, JS |
| Footer | ⭐⭐⭐ | Site footer | JavaScript |
| Power Virtual Agents | ⭐⭐⭐ | PVA chatbot | PVA SDK, Dataverse |
| Search | ⭐⭐⭐ | Search form | Bootstrap, Liquid |
| Default Studio Template | ⭐ | Page container | Liquid |
| Breadcrumbs | ⭐ | Navigation | Liquid |
| Languages Dropdown | ⭐ | Language selector | Liquid |

---

**Document Created:** December 3, 2025  
**Total Documentation Files:** 17 (16 templates + this summary)  
**Location:** `c:\RevOps\RevOps-Analysts\Documentation\Power Pages\Site\web-templates\`
