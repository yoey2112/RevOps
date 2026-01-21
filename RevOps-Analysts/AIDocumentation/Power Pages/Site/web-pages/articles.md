# Articles Web Page

## Overview
The Articles page displays individual knowledge articles with full content, formatting, and related information. It serves as the detailed view for accessing specific knowledge base content.

## Configuration

**Page ID:** `1de93212-c458-618a-858e-6bdcd876c31a`  
**Name:** Articles  
**Title:** View Knowledge Article  
**Partial URL:** `/articles`  
**Display Order:** 4

## Page Template

- **Template ID:** `e30ca546-4857-40d8-b068-fad5a61ddd34`
- **Template Name:** Default studio template

## Properties

- **Root Page:** Yes (`adx_isroot: true`)
- **Hidden from Sitemap:** Yes
- **Exclude from Search:** No
- **Enable Rating:** No
- **Enable Tracking:** No
- **Feedback Policy:** 756150000
- **Publishing State:** 81c6631c-ca6b-4b35-8228-8e759104c26e (Published)
- **Parent Page ID:** `366d00e9-84d6-baf4-0cb7-c847ef5ae6f2` (Knowledge Base)

## Entity Form

- **Entity Form ID:** `fc0d4a4f-b9f4-4c01-8cef-77f00c674cbd`
- The page uses an entity form for displaying knowledge article content

## Navigation

- Parent: Knowledge Base (`/knowledge-base`)
- URL: `/articles`
- Hidden from main sitemap navigation
- Accessed via links from knowledge base or search results

## Access Control

Access is controlled through:
- Web roles and authentication
- Knowledge Article Global Permission (Read)
- Only published articles are visible

## Purpose

The Articles page provides:
- Full knowledge article content display
- Formatted text with images and media
- Article metadata (author, date, category)
- Related articles suggestions
- Article feedback/rating capability
- Print-friendly article view

## Functionality

The page displays:
- Article title and summary
- Full article content with formatting
- Creation and modification dates
- Category and subject classification
- Related articles
- Article attachments
- Feedback options

## Content Features

Articles may include:
- Rich text content
- Images and diagrams
- Code snippets
- Step-by-step instructions
- Video embeds
- Downloadable attachments
- External links

## Related Components

- **Entity Form:** Knowledge article view form
  
- **Table Permissions:**
  - Knowledge Article Global Permission (Read)

- **Related Pages:**
  - Knowledge Base - Parent landing page
  - Category - Category-filtered views
  - Search - Article search results

## Article Metadata

Each article displays:
- Article number
- Title
- Summary/description
- Category
- Subject
- Keywords
- Author
- Published date
- Last modified date
- View count
- Rating

## User Experience

The page provides:
- Clean, readable article layout
- Responsive design for mobile viewing
- Print-friendly formatting
- Breadcrumb navigation
- Back to knowledge base link
- Related articles sidebar

## Related Documentation

- See `web-pages/knowledge-base.md` for knowledge base overview
- See `web-pages/category.md` for category browsing
- See `table-permissions/table-permissions-summary.md` for permissions
