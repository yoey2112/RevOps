# Search Web Page

## Overview
The Search page provides full-text search functionality across the Power Pages portal, allowing users to search for knowledge articles, cases, and other portal content.

## Configuration

**Page ID:** `d93548cb-d0ea-42d7-91a8-917bb33521a8`  
**Name:** Search  
**Partial URL:** `/search`  
**Display Order:** Not specified

## Page Template

- **Template ID:** `565d1f3d-3f2b-41d6-a2c1-ca084a117267`
- **Template Name:** Search page template (specialized template)

## Properties

- **Root Page:** Yes (`adx_isroot: true`)
- **Hidden from Sitemap:** Yes
- **Exclude from Search:** No
- **Enable Rating:** No
- **Enable Tracking:** No
- **Publishing State:** 81c6631c-ca6b-4b35-8228-8e759104c26e (Published)
- **Parent Page ID:** `60419c17-9d55-4eb3-b9d8-a0f182dc38e2` (Home)

## Navigation

- Parent: Home (`/`)
- URL: `/search`
- Hidden from main sitemap navigation
- Accessed via search box in header

## Access Control

Access is controlled through:
- Web roles and authentication
- Search results filtered by user permissions
- Only content user has access to appears in results

## Purpose

The Search page provides:
- Full-text search across portal content
- Filtered search results
- Relevance-based ranking
- Quick access to information
- Reduce time to find content

## Functionality

The page allows users to:
- Enter search queries
- View search results
- Filter by content type
- Sort by relevance or date
- Navigate to result items
- Refine searches

## Search Scope

Search includes:
- Knowledge articles
- Web pages
- Case information (user's own cases)
- Portal content
- File attachments

## Search Features

- **Full-text search:** Search across all text content
- **Relevance ranking:** Most relevant results first
- **Highlighting:** Search terms highlighted in results
- **Filtering:** Filter by content type, date, category
- **Pagination:** Navigate through result pages
- **Suggestions:** Did you mean / auto-suggest

## Related Components

- **Content Snippets:**
  - Search-Title: "Search"
  - Search-NoResults: "No results found."
  - Search-ResultsCount: Result count display
  - Search-ResultsTitle: Results header
  - Header-Search-Label: "Search Knowledge Base"
  - Header-Search-Tooltip: "Search"

- **Table Permissions:**
  - Knowledge Article Global Permission (Read)
  - Cases where contact is customer (Read)
  - Category Global Permission (Read)

- **Related Pages:**
  - Knowledge Base - Main knowledge base
  - Articles - Article viewing
  - View Case - Case viewing

## Search Results Display

Each result shows:
- Result title (linked)
- Content snippet/preview
- Content type indicator
- Last modified date
- Relevance score/ranking

## Result Snippets

Content snippets used:
- **Search-ResultsTitle:** `Results for {{ request.params.q }}`
- **Search-ResultsCount:** `{{ current_page }} - {{ page_size }} of {{ searchindex.approximate_total_hits }} Results`
- **Search-NoResults:** `No results found.`

## URL Parameters

Search page uses query parameters:
- `?q={search-term}` - Search query
- `?page={page-number}` - Pagination
- `?filter={content-type}` - Content filtering

## Search Integration

The search integrates with:
- Portal search index
- Azure Cognitive Search (if configured)
- Dataverse search
- Full-text indexing

## User Experience

The page provides:
- Prominent search input box
- Clear result presentation
- Result count and pagination
- Empty state messaging
- Mobile-responsive layout
- Fast search performance

## Performance Considerations

- Search results are cached
- Pagination for large result sets
- Maximum results limit
- Search index optimization

## Related Documentation

- See `content-snippets/search-*.md` for search snippet documentation
- See `web-pages/knowledge-base.md` for knowledge base integration
- See `table-permissions/table-permissions-summary.md` for access filtering
