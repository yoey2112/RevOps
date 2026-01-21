# Category Web Page

## Overview
The Category page displays a filtered list of knowledge articles belonging to a specific category. It provides organized navigation through the knowledge base by topic or subject area.

## Configuration

**Page ID:** `1436be4b-fc84-3f09-4546-018876ed5770`  
**Name:** Category  
**Title:** Category  
**Partial URL:** `/category`  
**Display Order:** 2

## Page Template

- **Template ID:** `e30ca546-4857-40d8-b068-fad5a61ddd34`
- **Template Name:** Default studio template

## Properties

- **Root Page:** Yes (`adx_isroot: true`)
- **Hidden from Sitemap:** Yes
- **Exclude from Search:** No
- **Enable Rating:** No
- **Enable Tracking:** No
- **Publishing State:** 81c6631c-ca6b-4b35-8228-8e759104c26e (Published)
- **Parent Page ID:** `366d00e9-84d6-baf4-0cb7-c847ef5ae6f2` (Knowledge Base)

## Navigation

- Parent: Knowledge Base (`/knowledge-base`)
- URL: `/category`
- Hidden from main sitemap navigation
- Accessed via category links from knowledge base

## Access Control

Access is controlled through:
- Web roles and authentication
- Category Global Permission (Read)
- Knowledge Article Global Permission (Read)
- All authenticated users can view categories

## Purpose

The Category page provides:
- Filtered view of articles by category
- Category description and metadata
- List of articles in the category
- Sub-category navigation (if applicable)
- Quick access to related content

## Functionality

The page allows users to:
- View all articles in a category
- Browse sub-categories
- Sort articles by relevance or date
- Navigate to individual articles
- Return to knowledge base home

## Category Organization

Categories may include:
- Product categories
- Feature areas
- Troubleshooting topics
- How-to guides
- Administrative tasks
- Integration topics
- Security and compliance

## Related Components

- **Lists:**
  - All Categories (web)
  - Category-filtered article lists
  
- **Table Permissions:**
  - Category Global Permission (Read)
  - Knowledge Article Global Permission (Read)

- **Related Pages:**
  - Knowledge Base - Parent page
  - Articles - Individual article viewing
  - Search - Cross-category search

## Category Display

Each category view shows:
- Category name and icon
- Category description
- Article count
- List of articles with:
  - Article title
  - Summary/excerpt
  - Last modified date
  - View count
  - Rating

## URL Pattern

Categories are accessed via URL parameters:
- `/category?id={category-id}`
- `/category?name={category-name}`

## User Experience

The page provides:
- Clear category identification
- Breadcrumb navigation
- Article preview cards
- Sorting and filtering options
- Pagination for large article sets
- Mobile-responsive layout

## Related Documentation

- See `web-pages/knowledge-base.md` for knowledge base overview
- See `web-pages/articles.md` for article viewing
- See `lists/All-Categories---web.md` and `lists/All-Categories.md`
- See `table-permissions/table-permissions-summary.md` for permissions
