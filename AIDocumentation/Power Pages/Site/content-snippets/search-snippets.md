# Search Related Content Snippets

## Overview
Multiple content snippets control the search functionality display, messages, and results presentation throughout the portal.

---

## Search Title

### Configuration
**Name:** Search-Title  
**Language:** English (US)

### Content
```html
<span>Search</span>
```

### Purpose
Provides the title/heading for the search page.

### Usage
- Search page header
- Search section titles

---

## Search No Results

### Configuration
**Name:** Search-NoResults  
**Language:** English (US)

### Content
```html
No results found.
```

### Purpose
Displays message when search returns zero results.

### Usage
- Empty state on search page
- No matches found message

---

## Search Results Count

### Configuration
**Name:** Search-ResultsCount  
**Language:** English (US)

### Content
```html
{{ current_page }} - {{ page_size }} of {{ searchindex.approximate_total_hits }} Results
```

### Purpose
Displays the count and range of search results being shown.

### Usage
- Search results page
- Results pagination info

### Liquid Variables
- `{{ current_page }}` - Current page number
- `{{ page_size }}` - Number of results per page
- `{{ searchindex.approximate_total_hits }}` - Total result count

### Example Output
```
1 - 10 of 45 Results
11 - 20 of 45 Results
```

---

## Search Results Title

### Configuration
**Name:** Search-ResultsTitle  
**Language:** English (US)

### Content
```html
Results for {{ request.params.q }}
```

### Purpose
Displays the search query that was submitted, showing what the user searched for.

### Usage
- Search results page header
- Query confirmation display

### Liquid Variables
- `{{ request.params.q }}` - The search query parameter from URL

### Example Output
```
Results for knowledge base
Results for license adjustment
Results for P2P transfer
```

---

## Implementation

All search snippets work together to create the search results experience:

### Search Page Structure
```html
<!-- Search Title -->
<h1>{{ snippets['Search-Title'] }}</h1>

<!-- Results Header (if results exist) -->
<h2>{{ snippets['Search-ResultsTitle'] }}</h2>

<!-- Results Count -->
<p>{{ snippets['Search-ResultsCount'] }}</p>

<!-- Results List -->
<div class="search-results">
  <!-- Result items here -->
</div>

<!-- No Results (if no results) -->
<p>{{ snippets['Search-NoResults'] }}</p>
```

## Localization

All search snippets support multiple languages for international users:
- English (en-US) - Default
- French (fr-FR) - If configured
- Additional languages as needed

## Customization

To modify search snippets:
1. Edit content snippets in Power Pages
2. Update text or Liquid logic
3. Maintain variable placeholders
4. Test search functionality
5. Verify pagination displays correctly
6. Publish changes

## Related Components

- **Web Pages:**
  - Search page
  - Knowledge Base
  
- **Content Snippets:**
  - Header-Search-Label
  - Header-Search-Tooltip

- **Functionality:**
  - Portal search index
  - Search results rendering
  - Pagination logic

## User Experience

These snippets provide:
- Clear search context
- Result count information
- Empty state messaging
- Query confirmation
- Professional search interface

## SEO Considerations

- Search title provides page context
- Results title shows user intent
- No results message prevents confusion
- Count information shows depth of content

## Testing Checklist

- [ ] Search with results shows proper count
- [ ] Search with no results shows "No results found"
- [ ] Results title displays query correctly
- [ ] Pagination updates count correctly
- [ ] Special characters in query display properly
- [ ] Localization works for all languages

## Related Documentation

- See `web-pages/search.md` for search page details
- See `content-snippets/header-search-label.md`
- See `content-snippets/header-search-tooltip.md`
