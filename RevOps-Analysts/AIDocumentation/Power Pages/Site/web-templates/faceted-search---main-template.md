# Faceted Search - Main Template Web Template

## Overview
The main container template for the faceted search functionality. Orchestrates the search UI by including sub-templates for facets, results, pagination, and sorting. Uses Handlebars.js for client-side rendering.

## Location
`c:\RevOps\Power Page Site\.paportal\swdevportal\web-templates\faceted-search---main-template\`

## Configuration
- **Template ID**: `2698e204-8726-f011-8c4d-7c1e5206727f`
- **Template Name**: `Faceted Search - Main Template`

## Custom Code

### Liquid Template Setup

**Configuration:**
```liquid
{% assign search_page = sitemarkers['Search'] %}
{% assign query = settings['search/query'] | default:'@(Query)' %}
```

**Main Container:**
```html
<div class="handlebars-search-container" 
     data-url="{{ search_page.url | h }}" 
     data-query="{{query}}">
  
  <div class="row search-body-container">
    <div class="col-xs-12 loader">
      <div class="fa-spin">
        <span class="fa fa-spinner fa-4x" aria-hidden="true"></span>
      </div>
    </div>
  </div>
  
  <!-- Facet Order Definition -->
  <div class="js-facet-order-definition hidden">
    <div class="facet-order-item">_logicalname</div>
    <div class="facet-order-item">modifiedon.date</div>
    <div class="facet-order-item">rating</div>
    <div class="facet-order-item">associated.product</div>
  </div>
  
  <!-- Include Sub-Templates -->
  {% include 'Faceted Search - Paging Template' %}
  {% include 'Faceted Search - Sort Template' %}  
  {% include 'Faceted Search - Facets Template' %}
  {% include 'Faceted Search - Results Template' %}  
</div>
```

### Handlebars Template

**Body Container Template:**
```handlebars
<script id="facets-view-body-container" type="text/x-handlebars-template">
  {{#if facetViews }}
    <!-- Layout with facets sidebar -->
    <div class="col-md-3 col-sm-4 hidden-xs _facets d-none"></div>  
    <div class="col-md-12 col-sm-12 col-xs-12 loader">
      <div class="fa-spin">
        <span class="fa fa-spinner fa-4x" aria-hidden="true"></span>
      </div>
    </div>
    <div class="col-md-12 col-sm-8 col-xs-12 js-search-body">
      <div class="hidden-xs search-order js-search-body pull-right"></div>
      <div class="search-results" role="alert"></div>
      <div class="search-pagination text-center"></div>
    </div>
  {{else}}
    <!-- Layout without facets -->
    <div class="col-md-12 col-sm-12 col-xs-12 js-search-body">
      <div class="hidden-xs search-order js-search-body pull-right"></div>
      <div class="search-results"></div>
      <div class="search-pagination text-center"></div>
    </div>  
  {{/if}}
</script>
```

### Key Features

1. **Facet Ordering:**
   - Defines display order for search facets
   - Hidden div with class `.js-facet-order-definition`
   - Facet types:
     - `_logicalname` - Record type filter
     - `modifiedon.date` - Date modified filter
     - `rating` - Rating filter
     - `associated.product` - Product filter

2. **Responsive Layout:**
   - With facets: 3-column sidebar + 9-column results
   - Without facets: Full-width results
   - Mobile: Stacks vertically (hidden-xs for facets)
   - Currently facets are hidden with `d-none` class

3. **Loading State:**
   - FontAwesome spinner (4x size)
   - Displayed during search execution
   - `.fa-spin` animation class

4. **Component Architecture:**
   - Main template serves as orchestrator
   - Sub-templates included via Liquid
   - Handlebars handles client-side rendering

5. **Data Attributes:**
   - `data-url` - Search page URL
   - `data-query` - Search query parameter

6. **ARIA Accessibility:**
   - `role="alert"` on search results container
   - `aria-hidden="true"` on spinner icon

## Usage

This template is rendered on the search page and initializes the faceted search interface. It's typically configured as the page template for the Search site marker page.

**JavaScript Integration:**
The template expects JavaScript to:
1. Read `data-url` and `data-query` attributes
2. Execute search queries
3. Render Handlebars templates with results
4. Update DOM elements:
   - `.search-results` - Search results list
   - `.search-pagination` - Pagination controls
   - `.search-order` - Sort options
   - `._facets` - Filter facets

## Related Components

- **Web Templates:**
  - `Faceted Search - Paging Template` - Pagination UI
  - `Faceted Search - Sort Template` - Sort dropdown
  - `Faceted Search - Facets Template` - Filter sidebar
  - `Faceted Search - Results Template` - Results display

- **Site Markers:**
  - `Search` - Search page URL

- **Site Settings:**
  - `search/query` - Query parameter configuration

- **JavaScript Libraries:**
  - Handlebars.js - Client-side templating
  - FontAwesome - Icons

- **Facet Types:**
  - Record Type (`_logicalname`)
  - Modified Date (`modifiedon.date`)
  - Rating (`rating`)
  - Associated Product (`associated.product`)

## Change History
- Implemented faceted search architecture
- Added facet order definition for consistent display
- Configured responsive layout (currently hiding facet sidebar)
- Integrated loading spinner
- Added Handlebars template for dynamic rendering
- ARIA accessibility attributes
- Support for facet-less search results view
