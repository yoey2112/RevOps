# Article Web Template

## Overview
Displays a knowledge base article with metadata (created/modified dates) and custom date formatting. Retrieves article content via FetchXML and formats dates dynamically with JavaScript.

## Location
`c:\RevOps\Power Page Site\.paportal\swdevportal\web-templates\article\`

## Configuration
- **Template Name**: `Article`
- **Query Parameter**: `id` - Article public number (format: `KA-####`)

## Custom Code

### Liquid Data Retrieval

**Parse Article ID:**
```liquid
{% assign articleIdParts = request.params["id"] | split: '-' %}
{% assign articleId = articleIdParts[0] | append: '-' | append: articleIdParts[1] %}
```
This extracts the first two parts of the ID (e.g., `KA-0001` from `KA-0001-title-slug`)

### FetchXML Query

```xml
<fetch top="1">
  <entity name="knowledgearticle">
    <attribute name="articlepublicnumber" />
    <attribute name="title" />
    <attribute name="content" />
    <attribute name="modifiedon" />
    <attribute name="createdon" />
    <filter>
      <condition attribute="articlepublicnumber" operator="eq" value="{{ articleId }}" />
      <condition attribute="isinternal" operator="eq" value="0" />  <!-- External only -->
      <condition attribute="isprimary" operator="eq" value="1" />   <!-- Primary version -->
      <condition attribute="isrootarticle" operator="eq" value="0" />  <!-- Not root -->
      <condition attribute="statecode" operator="eq" value="3" />   <!-- Published -->
    </filter>
  </entity>
</fetch>
```

**Filters Applied:**
- External articles only (`isinternal = 0`)
- Primary version (`isprimary = 1`)
- Not root article (`isrootarticle = 0`)
- Published state (`statecode = 3`)

### HTML Structure

```html
<div class="article-container">
  {% for article in articleQuery.results.entities limit:1 %}
    <h1 class="d-none">{{ article.title }}</h1>
    
    <div class="d-flex gap-4 small align-items-center pt-5">
      <p class="meta mb-0">
        Created on: <span class="date-format" data-date="{{ article.createdon }}"></span>
      </p>
      <p class="meta mb-0">
        Modified on: <span class="date-format" data-date="{{ article.modifiedon }}"></span>
      </p>
    </div>

    <div class="content">
      {{ article.content }}
    </div>
  {% endfor %}
</div>
```

### JavaScript Date Formatting

**IIFE Implementation:**
```javascript
(function () {
  function formatDates(config = {}) {
    const settings = {
      selectors: config.selectors || ".date-format",
      locale: config.locale || "en-US",
      options: config.options || {
        year: "numeric",
        month: "long",
        day: "numeric"
      },
      dateAttribute: config.dateAttribute || "data-date",
    };

    const selectors = Array.isArray(settings.selectors)
      ? settings.selectors
      : [settings.selectors];

    selectors.forEach(selector => {
      const elements = document.querySelectorAll(selector);

      if (!elements.length) {
        console.warn(`No elements found for selector: ${selector}`);
        return;
      }

      elements.forEach(element => {
        try {
          let dateValue = element.getAttribute(settings.dateAttribute);
          const dateObj = new Date(dateValue)

          if (!dateObj || isNaN(dateObj.getTime())) {
            console.warn(`Invalid date for element: ${element.outerHTML}`);
            return;
          }

          element.textContent = dateObj.toLocaleDateString(
            settings.locale, 
            settings.options
          );
        } catch (err) {
          console.error(`Error formatting date: ${err.message}`);
        }
      });
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    formatDates({
      selectors: ".date-format",
      locale: "en-US",
      options: {
        year: "numeric",
        month: "long",
        day: "numeric"
      }
    });
  });
})();
```

**Features:**
- Configurable locale (default: "en-US")
- Configurable date format options
- Error handling with console warnings
- Multiple selector support
- Prevents global variable pollution (IIFE)

### CSS Styling

```css
.article-container {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
  font-family: Arial, sans-serif;
  max-width: 80%;
  margin: auto;
}

h1 {
  color: #333;
}

.meta {
  font-size: 14px;
  color: #666;
}

.content {
  margin-top: 15px;
  line-height: 1.6;
}
```

### Key Features

1. **Article ID Parsing:**
   - Extracts article number from URL slug
   - Format: `KA-####-optional-title-slug`
   - Only uses first two parts for lookup

2. **Date Formatting:**
   - Server-side date values in `data-date` attributes
   - Client-side JavaScript formatting
   - Locale-aware formatting (default: en-US)
   - Format: "Month Day, Year" (e.g., "December 3, 2025")

3. **Article Filtering:**
   - Only published articles
   - Primary version only (not drafts/translations)
   - External articles (not internal KB)
   - Non-root articles

4. **Metadata Display:**
   - Created date
   - Modified date
   - Flexbox layout with gap spacing

5. **Content Rendering:**
   - Raw HTML content from `article.content` field
   - Allows rich formatting (images, links, etc.)

6. **Responsive Design:**
   - Max width: 80%
   - Centered container
   - Clean, readable layout

7. **Hidden Title:**
   - H1 with `.d-none` for SEO
   - Title likely displayed elsewhere (breadcrumb, page title)

8. **Error Handling:**
   - Date parsing validation
   - Console warnings for issues
   - Graceful fallback

## Usage

**URL Format:**
```
/article?id=KA-0001-article-title-slug
/article?id=KA-0123
```

**Page Configuration:**
- Set this template as the page template for article pages
- Configure URL structure in site settings
- Ensure query parameter `id` is passed

## Related Components

- **Entities:**
  - `knowledgearticle` - KB article data

- **Article Properties:**
  - `articlepublicnumber` - Public article ID (KA-####)
  - `title` - Article title
  - `content` - Rich HTML content
  - `createdon` - Creation date
  - `modifiedon` - Last modified date
  - `isinternal` - Internal/external flag
  - `isprimary` - Primary version flag
  - `isrootarticle` - Root article flag
  - `statecode` - Publication state

- **JavaScript Libraries:**
  - Native Date API
  - Native DOM API (querySelector, getAttribute)

## Change History
- Implemented article ID parsing from URL slug
- Added FetchXML query with comprehensive filters
- Client-side date formatting with locale support
- IIFE to prevent global namespace pollution
- Responsive container with max-width
- Metadata display (created/modified dates)
- Error handling and console logging
- Clean, modern CSS styling

## Recommendations
- Consider adding article rating/feedback widget
- Add social sharing buttons
- Implement related articles section
- Add breadcrumb navigation
- Consider print-friendly styling
- Add table of contents for long articles
- Consider analytics tracking (page views)
- Could enhance with article views increment
