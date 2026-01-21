# Faceted Search - Results Template Web Template

## Overview
Defines the Handlebars template for rendering search results with custom styling. Displays search results in a list format with article icons, titles, fragments, and parent article references.

## Location
`c:\RevOps\Power Page Site\.paportal\swdevportal\web-templates\faceted-search---results-template\`

## Configuration
- **Template ID**: `a476fd14-8726-f011-8c4d-7c1e5206727f`
- **Template Name**: `Faceted Search - Results Template`

## Custom Code

### CSS Styling

**Search Result Items:**
```css
.search-results li .icon-holder {
  min-width: 40px;
  max-width: 40px;
}

.search-results li h3 a {
  font-size: 20px;
  font-weight: bold;
  transition: color .35s ease-in-out;
}

.search-results li p {
  font-size: 16px;
}

.search-results h2 {
  font-size: 21px;
  margin-bottom: 0;
  padding-bottom: 0;
}
```

**Pagination Styling:**
```css
ul.pagination {
  display: flex;
  justify-content: center;
  list-style: none;
}

ul.pagination li {
  border: 1px solid #cccccc;
  padding: 0 1rem;
  height: 35px;
  line-height: 35px;
  font-family: Montserrat;
}

ul.pagination li a {
  font-size: 19px;
}

ul.pagination li:not(:first-child) {
  border-left-width: 0;
  box-shadow: 0 3px 10px rgba(0, 0, 0, 0.05);
}
```

### Handlebars Template

**Results Header:**
```handlebars
{{#if items}}
  <div class="page-header">
    <h2>
      {{ stringFormat "{{ resx.Search_Results_Format_String }}" firstResultNumber lastResultNumber itemCount }}
      <em class="querytext">{{{query}}}</em>
      {{#if isResetVisible}}
        <a class="btn btn-default btn-sm facet-clear-all" role="button" 
           title="{{ snippets['Search/Facet/ClearConstraints'] }}" tabIndex="0">
          {{ snippets['Search/Facet/ClearConstraints'] }}
        </a>
      {{/if}}
    </h2>
  </div>
```

**Results List:**
```handlebars
<ul>
  {{#each items}}
    <li class="d-flex align-items-center gap-4 pb-4">
      <div class="icon-holder">
        <i class="fa-light fa-light fa-file icon-article" aria-hidden="true"></i>
      </div>
      <div class="">
        <h3 class="mt-0 mb-1">
          <a title="{{title}}" href="{{url}}">
            {{#if parent}}
              <span class="glyphicon glyphicon-file pull-left text-muted" aria-hidden="true"></span>
            {{/if}}
            {{title}}
          </a>
        </h3>
        <p class="fragment">{{{fragment}}}</p>
      </div>
      {{#if parent}}
        <p class="small related-article">
          {{ resx.Related_Article }}: 
          <a title="{{parent.title}}" href="{{parent.absoluteUrl}}">{{parent.title}}</a>
        </p>
      {{/if}}
    </li>
  {{/each}}
</ul>
```

**No Results State:**
```handlebars
{{else}}
  <h2>
    {{ resx.Search_No_Results_Found }}
    <em class="querytext">{{{query}}}</em>
    {{#if isResetVisible}}
      <a class="btn btn-default btn-sm facet-clear-all" role="button" 
         title="{{ snippets['Search/Facet/ClearConstraints'] }}" tabIndex="0">
        {{ snippets['Search/Facet/ClearConstraints'] }}
      </a>
    {{/if}}
  </h2>
{{/if}}
```

**Related Notes (Commented Out):**
```handlebars
<!-- <ul class="note-group small list-unstyled">
  {{#if relatedNotes}}
    {{#each relatedNotes}}
      <li class="note-item">
        {{#if isImage}}
          <a target="_blank" title="{{title}}" href="{{absoluteUrl}}">
            <span class="glyphicon glyphicon-file" aria-hidden="true"></span>&nbsp;{{title}}
          </a>
        {{else}}
          <a title="{{title}}" href="{{absoluteUrl}}">
            <span class="glyphicon glyphicon-file" aria-hidden="true"></span>&nbsp;{{title}}
          </a>
        {{/if}}
        <p class="fragment text-muted">{{{fragment}}}</p>
      </li>
    {{/each}}
  {{/if}}
</ul> -->
```

### Liquid-Handlebars Bridge

**Variable Declaration:**
```liquid
{% assign openTag = '{{' %}
{% assign closingTag = '}}' %}
```

This allows Liquid to output Handlebars syntax without processing it.

### Key Features

1. **Search Result Display:**
   - Article icon with fixed width container (40px)
   - Bold article title (20px)
   - Fragment/excerpt text (16px)
   - Flexbox layout with gap spacing

2. **Result Metadata:**
   - Result count: "Results X-Y of Z"
   - Query display in emphasis tag
   - Parent article reference (if applicable)

3. **Clear Filters Button:**
   - Shown when `isResetVisible` is true
   - Resets all active facet filters
   - Accessible via keyboard (tabIndex="0")

4. **Parent Article Links:**
   - Shows "Related Article" label
   - Links to parent article
   - Displayed for child articles

5. **Icons:**
   - FontAwesome Light file icon
   - Glyphicon for parent article indicator
   - Fixed-width icon container

6. **Empty State:**
   - "No results found" message
   - Query display
   - Clear filters option

7. **Pagination Integration:**
   - Custom Montserrat font
   - Border and shadow styling
   - Centered layout
   - Connected buttons (shared borders)

8. **Related Notes Feature:**
   - Currently disabled (commented out)
   - Would display attachments/notes
   - Image detection for target="_blank"

## Usage

This template is automatically included by the `Faceted Search - Main Template` and rendered via JavaScript when search results are available.

**Expected Data Structure:**
```javascript
{
  items: [
    {
      title: "Article Title",
      url: "/article-url",
      fragment: "Article excerpt...",
      parent: {  // Optional
        title: "Parent Article",
        absoluteUrl: "/parent-url"
      }
    }
  ],
  query: "search query",
  firstResultNumber: 1,
  lastResultNumber: 10,
  itemCount: 50,
  isResetVisible: true
}
```

## Related Components

- **Web Templates:**
  - `Faceted Search - Main Template` - Container template
  - `Faceted Search - Paging Template` - Pagination
  - `Faceted Search - Facets Template` - Filters
  - `Faceted Search - Sort Template` - Sorting

- **JavaScript:**
  - Search API integration
  - Handlebars.js rendering engine
  - Result data transformation

- **Icons:**
  - FontAwesome Light (fa-file)
  - Bootstrap Glyphicons (fallback)

- **Resource Strings:**
  - `resx.Search_Results_Format_String`
  - `resx.Related_Article`
  - `resx.Search_No_Results_Found`
  - `snippets['Search/Facet/ClearConstraints']`

## Change History
- Custom icon holder with fixed width
- FontAwesome Light icons instead of Glyphicons
- Flexbox layout with gap utilities
- Custom pagination styling with Montserrat font
- Parent article reference display
- Related notes feature (disabled)
- Clear filters functionality
- No results state handling
- Responsive design with Bootstrap utilities
