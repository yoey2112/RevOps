# Search Web Template

## Overview
Renders the search form with input field, optional filter dropdown, and submit button. Integrates with the site's search functionality and supports filtered search by entity type.

## Location
`c:\RevOps\Power Page Site\.paportal\swdevportal\web-templates\search\`

## Configuration
- **Template Name**: `Search`
- **Input Parameter**: `search_id` - ID for the search input field

## Custom Code

### Liquid Configuration

**Settings:**
```liquid
{% assign search_enabled = settings['search/enabled'] | boolean | default:true %}
{% assign search_page = sitemarkers['Search'] %}
{% assign search_filters = settings['search/filters'] | search_filter_options %}
{% assign defaultSearchFilterText = snippets["Search/Default/FilterText"] | default: resx["All"] | h %}
{% assign searchFilterLabel = snippets["Header/Search/FilterLabel"] | default: resx["Search_Filter"] | h %}
{% assign formId = uniqueid.new_guid %}
```

### HTML Form Structure

**Main Form:**
```html
<form method="GET" action="{{ search_page.url | h }}" role="search" class="form-search" data-test="true">
    <div class="input-group justify-content-center">
        <!-- Filter Dropdown (Optional) -->
        <!-- Search Input -->
        <!-- Submit Button -->
    </div>
</form>
```

### Filter Dropdown (Conditional)

**Dropdown Button:**
```html
{% if search_filters %}
  <div class="btn-group btn-select input-group-btn" 
       data-bs-target="#filter-{{ formId }}" 
       data-focus="#{{search_id}}">
    <li class="dropdown-submenu dropdown nav-item">
      <button id="search-filter" type="button" 
              class="btn btn-default dropdown-toggle"
              data-bs-toggle="dropdown"
              aria-haspopup="true" 
              aria-label="{{ searchFilterLabel }}" 
              aria-expanded="false">
        <span class="selected">{{ defaultSearchFilterText }}</span>
        <span class="   "></span>
      </button>
      <ul class="dropdown-menu" role="listbox" aria-label="{{ searchFilterLabel }}">
        <li role="presentation">
          <a class="dropdown-item" href="#" role="option" 
             data-value=""
             aria-label="{{ defaultSearchFilterText }}" 
             aria-selected="false" 
             tabIndex="-1">
            {{ defaultSearchFilterText }}
          </a>
        </li>
        {% for search_filter_option in search_filters %}
          <li role="presentation">
            <a class="dropdown-item" href="#" role="option" 
               data-value="{{ search_filter_option.value | h }}"
               aria-label="{{ search_filter_option.display_name | h }}" 
               aria-selected="false" 
               tabIndex="-1">
              {{ search_filter_option.display_name | h }}
            </a>
          </li>
        {% endfor %}
      </ul>
    </li>
  </div>
  
  <!-- Hidden Select Element -->
  <label for="filter-{{ formId }}" class="visually-hidden">{{ searchFilterLabel }}</label>
  <select id="filter-{{ formId }}" name="logicalNames" 
          class="btn-select" aria-hidden="true" 
          data-query="logicalNames">
    <option value="" selected="selected">{{ defaultSearchFilterText }}</option>
    {% for search_filter_option in search_filters %}
      <option value="{{ search_filter_option.value | h }}">
        {{ search_filter_option.display_name | h }}
      </option>
    {% endfor %}
  </select>
{% endif %}
```

### Search Input

```html
<div class="d-flex gap-4">
  <label for="{{search_id}}" class="visually-hidden">
    {{ snippets["Header/Search/Label"] | default: resx["Search_DefaultText"] | h }}
  </label>
  <input type="text" 
         class="form-control" 
         id="{{search_id}}" 
         name="q"
         placeholder="{{ snippets["Header/Search/Label"] | default: resx["Search_DefaultText"] | h }}"
         value="{{ params.q | escape }}"
         title="{{ snippets["Header/Search/Label"] | default: resx["Search_DefaultText"] | h }}">
  
  <div class="input-group-btn">
    <button type="submit" 
            class="btn btn-primary"
            title="{{ snippets["Header/Search/ToolTip"] | default: resx["Search_DefaultText"] | h }}"
            aria-label="{{ snippets["Header/Search/ToolTip"] | default: resx["Search_DefaultText"] | h }}">
      <span class="fa fa-search" aria-hidden="true"></span>
    </button>
  </div>
</div>
```

### Key Features

1. **Conditional Rendering:**
   - Only renders if search is enabled (`settings['search/enabled']`)
   - Only renders if search page site marker exists
   - Filter dropdown only shown if filters are configured

2. **Search Filters:**
   - Dropdown to filter by entity type (logical name)
   - Retrieved from `settings['search/filters']`
   - Examples: Knowledge Articles, Forum Posts, Web Pages
   - "All" option to clear filter

3. **Form Submission:**
   - Method: GET (query parameters)
   - Action: Search page URL from site marker
   - Parameters:
     - `q` - Search query text
     - `logicalNames` - Optional filter (if selected)

4. **Accessibility:**
   - Hidden labels for screen readers (`.visually-hidden`)
   - ARIA labels and roles
   - Keyboard navigation support (tabIndex)
   - Role="search" on form
   - Role="listbox" for filter dropdown

5. **Bootstrap Integration:**
   - Input groups for layout
   - Dropdown menus
   - Button styling
   - Gap utilities (gap-4)
   - Flexbox layout (d-flex)

6. **Unique IDs:**
   - Generates unique form ID per instance (`uniqueid.new_guid`)
   - Prevents ID conflicts with multiple search forms

7. **Pre-populated Query:**
   - Displays current query: `value="{{ params.q | escape }}"`
   - Maintains user input on page reload

8. **Icon:**
   - FontAwesome search icon (fa-search)
   - Hidden from screen readers (aria-hidden="true")

## Usage

**Header Integration:**
```liquid
<div class="dropdown-menu dropdown-search">
  {% include 'Search', search_id:'q' %}
</div>
```

**Standalone Search Page:**
```liquid
{% include 'Search' search_id:'search_control' %}
```

**Parameters:**
- `search_id` (required) - Unique ID for the search input element

## Related Components

- **Web Templates:**
  - `Header` - Includes search in dropdown
  - `Faceted Search - Main Template` - Search results display

- **Site Settings:**
  - `search/enabled` - Enable/disable search
  - `search/filters` - Configure filter options

- **Site Markers:**
  - `Search` - Search results page URL

- **Content Snippets:**
  - `Search/Default/FilterText` - Default filter text ("All")
  - `Header/Search/Label` - Search input label/placeholder
  - `Header/Search/ToolTip` - Search button tooltip
  - `Header/Search/FilterLabel` - Filter dropdown label

- **Resource Strings:**
  - `resx["All"]` - Default filter text
  - `resx["Search_Filter"]` - Filter label
  - `resx["Search_DefaultText"]` - Search placeholder

- **Query Parameters:**
  - `q` - Search query
  - `logicalNames` - Entity filter (comma-separated)

## Change History
- Bootstrap 5 update (data-bs-* attributes)
- Flexbox layout with gap utilities
- Unique form ID generation
- Accessible form controls with ARIA
- Filter dropdown integration
- Pre-population of search query
- Visually hidden labels for accessibility
