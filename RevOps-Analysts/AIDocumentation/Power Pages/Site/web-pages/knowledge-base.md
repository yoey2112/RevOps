# Knowledge Base Web Page

## Overview
The Knowledge Base page serves as the main entry point for accessing self-service solutions, articles, and documentation. It provides users with access to published knowledge articles organized by categories and topics.

## Configuration

**Page ID:** `366d00e9-84d6-baf4-0cb7-c847ef5ae6f2`  
**Name:** Knowledge Base  
**Title:** Solutions  
**Partial URL:** `/knowledge-base`  
**Display Order:** 11

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
- **Parent Page ID:** `60419c17-9d55-4eb3-b9d8-a0f182dc38e2` (Home)

## Child Pages

- **Articles** - View individual knowledge articles
- **Category** - Browse articles by category

## Navigation

- Parent: Home (`/`)
- URL: `/knowledge-base`
- Hidden from main sitemap navigation
- Accessible through main navigation menu

## Access Control

Access is controlled through:
- Web roles and authentication
- Knowledge Article Global Permission (Read only)
- Category Global Permission (Read only)
- All authenticated users can view published articles

## Purpose

The Knowledge Base page provides:
- Central hub for self-service support
- Browse and search knowledge articles
- Access to solutions and documentation
- Category-based article organization
- Quick answers to common questions
- Reduce support ticket volume

## Functionality

The page allows users to:
- Browse articles by category
- Search knowledge base content
- View popular or featured articles
- Access solution guides
- Read troubleshooting documentation
- Find answers independently

## Related Components

- **Lists:**
  - All Categories - web
  - Knowledge article listings
  
- **Table Permissions:**
  - Knowledge Article Global Permission (Read)
  - Category Global Permission (Read)

- **Related Pages:**
  - Articles - Individual article viewing
  - Category - Category-filtered article lists
  - Search - Knowledge base search

## Knowledge Article Access

- **Entity:** knowledgearticle
- **Scope:** Global (756150000)
- **Permissions:** Read only
- **Status:** Only published articles visible

## Categories

Categories organize articles by topic:
- Product documentation
- Troubleshooting guides
- How-to articles
- FAQ sections
- Best practices
- Known issues

## Content Structure

Knowledge base contains:
- Article title and summary
- Detailed instructions
- Screenshots and diagrams
- Related articles
- Article ratings
- Last updated date

## Search Integration

The knowledge base integrates with the portal search:
- Full-text search of articles
- Category filtering
- Relevance ranking
- Search result highlighting

## Use Cases

Common knowledge base scenarios:
- Self-service problem resolution
- Product feature learning
- Configuration guidance
- Troubleshooting steps
- API documentation
- Integration guides

## Related Documentation

- See `web-pages/articles.md` for article viewing
- See `web-pages/category.md` for category browsing
- See `web-pages/search.md` for search functionality
- See `lists/All-Categories---web.md` and `lists/All-Categories.md`
- See `table-permissions/table-permissions-summary.md` for permissions
