# Faceted Search - Facets Template Web Template

## Overview
Defines the Handlebars templates for rendering search filter facets (Record Type, Modified Date, Rating, and Product). Provides interactive filtering UI with checkboxes, radio buttons, and list selections. Currently hidden via CSS in the main template.

## Location
`c:\RevOps\Power Page Site\.paportal\swdevportal\web-templates\faceted-search---facets-template\`

## Configuration
- **Template ID**: `8f7659ed-8626-f011-8c4d-7c1e5206727f`
- **Template Name**: `Faceted Search - Facets Template`

## Custom Code

### Handlebars Template Structure

**Container Template:**
```handlebars
<script id="facets-view-results" type="text/x-handlebars-template">
  {{#each facetViews}}
    <!-- Individual facet templates -->
  {{/each}}
</script>
```

### Facet Types

#### 1. Record Type Facet (`_logicalname`)

**Purpose:** Filter by entity/record type (e.g., Knowledge Article, Forum Post, etc.)

**Template:**
```handlebars
{{#ifvalue facetName value="_logicalname"}}
  {{#if facetData}}
    <div class="facet-view short-list panel panel-default d-none">
      <div class="facet-title panel-heading">
        {{ snippets['Search/Facet/RecordType'] }}
      </div>
      <div class="panel-body">
        <ul class="facet-list-group" role="listbox" 
            aria-label="{{ snippets['Search/Facet/RecordType'] }}">
          {{#each facetData}}
            <li class="facet-list-group-item clearfix control-item {{#if active}}active{{/if}}"
                tabIndex="0"
                data-facet="{{../facetName}}" 
                data-control-value="{{name}}"
                role="option" 
                aria-label="{{labelText}}" 
                title="{{labelText}}" 
                aria-selected="{{#if active}}true{{else}}false{{/if}}" 
                aria-checked="{{#if active}}true{{else}}false{{/if}}">
              <span class="facet-list-group-item-count pull-right">{{hitCount}}</span>
              <div class="facet-list-group-item-title-container">
                <span class="facet-list-group-item-title pull-left">{{displayName}}</span>
              </div>
            </li>
          {{/each}}
          <button type="button" class="show-more btn btn-link btn-xs" tabIndex="0">
            {{ snippets['Search/Facet/More'] }}
          </button>
          <button type="button" class="show-less btn btn-link btn-xs" tabIndex="0">
            {{ snippets['Search/Facet/Less'] }}
          </button>
        </ul>
      </div>
    </div>
  {{/if}}
{{/ifvalue}}
```

**Features:**
- Multi-select list (role="listbox")
- Show more/less buttons for long lists
- Hit count displayed per option
- Keyboard accessible (tabIndex="0")

#### 2. Modified Date Facet (`modifiedon.date`)

**Purpose:** Filter by date ranges (Last 24 hours, Last week, etc.)

**Template:**
```handlebars
{{#ifvalue facetName value="modifiedon.date"}}
  {{#if noData}}
  {{else}}
    <div class="facet-view panel panel-default d-none">
      <div class="facet-title panel-heading">
        {{ snippets['Search/Facet/ModifiedDate'] }}
      </div>
      <div class="panel-body">
        <ul class="facet-list-group" role="radiogroup" 
            aria-label="{{ snippets['Search/Facet/ModifiedDate'] }}">
          {{#each facetData}}
            <li class="facet-list-group-item clearfix control-item {{#if active}}active{{/if}}" 
                tabIndex="0" 
                data-facet="{{../facetName}}" 
                data-control-value="{{name}}"
                role="radio" 
                aria-label="{{labelText}}" 
                title="{{labelText}}" 
                aria-checked="{{#if active}}true{{else}}false{{/if}}">
              <span class="facet-list-group-item-count pull-right">{{hitCount}}</span>
              <div class="facet-list-group-item-title-container radio">
                <label>
                  <input type="radio" name="{{../facetName}}" value="{{name}}" 
                         {{#if active}}checked{{/if}} tabindex="-1" role="presentation">
                  {{displayName}}
                </label>
              </div>
            </li>
          {{/each}}
        </ul>
      </div>
    </div>
  {{/if}}
{{/ifvalue}}
```

**Features:**
- Single-select (role="radiogroup")
- Radio button inputs
- Hit count per date range
- Hidden if no data available

#### 3. Rating Facet (`rating`)

**Purpose:** Filter by article rating (star-based)

**Template:**
```handlebars
{{#ifvalue facetName value="rating"}}
  {{#if facetData}}
    <div class="facet-view short-list panel panel-default d-none">
      <div class="facet-title panel-heading">
        {{ snippets['Search/Facet/Rating'] }}
      </div>
      <div class="panel-body">
        <ul class="facet-list-group rating-facet-group" role="listbox" 
            aria-label="{{ snippets['Search/Facet/Rating'] }}">
          {{#each facetData}}
            {{#if skipStars}}
              <!-- "All" option -->
              <li class="facet-list-group-item clearfix control-item {{#if ../noActive}}active{{/if}}" 
                  data-facet="{{../facetName}}" 
                  data-control-value="" 
                  tabIndex="{{#if ../noActive}}0{{else}}-1{{/if}}"
                  role="option" 
                  aria-label="{{ snippets['Search/Facet/All'] }} {{hitCount}}" 
                  aria-selected="{{#if ../noActive}}true{{else}}false{{/if}}" 
                  aria-checked="{{#if ../noActive}}true{{else}}false{{/if}}">
                <span class="facet-list-group-item-title pull-left">
                  {{ snippets['Search/Facet/All'] }}
                </span>
              </li>
            {{else}}
              <!-- Star rating option -->
              <li class="facet-list-group-item clearfix control-item {{#if active}}active{{/if}}" 
                  data-facet="{{../facetName}}" 
                  data-control-value="{{name}}" 
                  tabIndex="{{#if active}}0{{else}}-1{{/if}}"
                  role="option" 
                  aria-label="{{ratingLabel}} {{hitCount}}" 
                  aria-selected="{{#if active}}true{{else}}false{{/if}}" 
                  aria-checked="{{#if active}}true{{else}}false{{/if}}">
                <span aria-label="{{ratingLabel}}" class="facet-list-group-item-title">
                  {{#each filledStars}}
                    <span class="rating-star rating-star-filled"></span>
                  {{/each}}
                  {{#each emptyStars}}
                    <span class="rating-star rating-star-empty"></span>
                  {{/each}}
                  <span aria-hidden="true">{{ resx.Facet_Rating_And_Up }}</span>
                </span>
                <span class="facet-list-group-item-count pull-right">{{hitCount}}</span>
              </li>
            {{/if}}
          {{/each}}
        </ul>
      </div>
    </div>
  {{/if}}
{{/ifvalue}}
```

**Features:**
- Visual star display (filled/empty)
- "X stars and up" filtering
- "All" option to clear filter
- Accessible labels for screen readers

#### 4. Product Facet (`associated.product`)

**Purpose:** Filter by associated product

**Template:**
```handlebars
{{#ifvalue facetName value="associated.product"}}
  {{#if facetData}}
    <div class="facet-view facet-view-multiple-select short-list panel panel-default d-none">
      <div class="facet-title panel-heading">
        {{ snippets['Search/Facet/Product'] }}
      </div>
      <div class="panel-body">
        <ul class="facet-list-group" aria-label="{{ snippets['Search/Facet/Product'] }}">
          <!-- "All" option -->
          <li class="facet-list-group-item clearfix control-item {{#if noActive}}active{{/if}}" 
              data-facet="{{../facetName}}" 
              data-control-value="" 
              tabIndex="{{#if noActive}}0{{else}}-1{{/if}}"
              aria-label="{{ snippets['search/facet/all'] }}" 
              aria-selected="{{#if noActive}}true{{else}}false{{/if}}">
            <span class="facet-list-group-item-title pull-left">
              {{ snippets['search/facet/all'] }}
            </span>
          </li>
          
          <!-- Product options -->
          {{#each facetData}}
            <li class="facet-list-group-item clearfix control-item {{#if active}}active{{/if}}" 
                data-facet="{{../facetName}}" 
                data-control-value="{{name}}"
                tabIndex="{{#if active}}0{{else}}-1{{/if}}" 
                aria-label="{{displayName}} {{hitCount}}" 
                aria-selected="{{#if active}}true{{else}}false{{/if}}"
                role="checkbox" 
                aria-checked="{{#if active}}true{{else}}false{{/if}}" 
                data-control-display-name="{{displayName}}">
              <span class="facet-list-group-item-count pull-right">{{hitCount}}</span>
              <div class="facet-list-group-item-title-container">
                <label class="facet-list-group-item-title pull-left">
                  <input type="checkbox" {{#if active}}checked{{/if}} 
                         tabindex="-1" role="presentation"/>
                  {{displayName}}
                </label>
              </div>
            </li>
          {{/each}}
          
          <button type="button" class="show-more btn btn-link btn-xs" tabIndex="0">
            {{ snippets['Search/Facet/More'] }}
          </button>
          <button type="button" class="show-less btn btn-link btn-xs" tabIndex="0">
            {{ snippets['Search/Facet/Less'] }}
          </button>
        </ul>
      </div>
    </div>
  {{/if}}
{{/ifvalue}}
```

**Features:**
- Multi-select with checkboxes (role="checkbox")
- "All" option to clear selection
- Show more/less buttons
- Hit count per product

### Common Features Across All Facets

1. **Accessibility:**
   - ARIA roles (listbox, radiogroup, checkbox, option)
   - ARIA labels and selected states
   - Keyboard navigation (tabIndex management)
   - Screen reader friendly

2. **Active State Management:**
   - `.active` class on selected items
   - `aria-selected` and `aria-checked` attributes
   - Visual indicators for selections

3. **Hit Counts:**
   - Displayed on right side (`.pull-right`)
   - Shows number of results per facet option

4. **Show More/Less:**
   - Expandable lists for long facet options
   - Button controls for user interaction

5. **Data Attributes:**
   - `data-facet` - Facet name/identifier
   - `data-control-value` - Selected value
   - `data-control-display-name` - Display text

6. **CSS Classes:**
   - `d-none` - Currently hidden
   - `.panel` / `.panel-default` - Bootstrap panels
   - `.short-list` - Indicates collapsible list

## Usage

This template is included by the `Faceted Search - Main Template` and rendered by JavaScript when facet data is available. Currently disabled with `d-none` CSS class.

**Expected Data Structure:**
```javascript
{
  facetViews: [
    {
      facetName: "_logicalname",
      facetData: [
        {
          name: "knowledgearticle",
          displayName: "Knowledge Article",
          labelText: "Knowledge Article",
          hitCount: 42,
          active: false
        }
      ]
    }
  ]
}
```

## Related Components

- **Web Templates:**
  - `Faceted Search - Main Template` - Container
  - `Faceted Search - Results Template` - Results display

- **Resource Strings:**
  - `snippets['Search/Facet/RecordType']`
  - `snippets['Search/Facet/ModifiedDate']`
  - `snippets['Search/Facet/Rating']`
  - `snippets['Search/Facet/Product']`
  - `snippets['Search/Facet/More']`
  - `snippets['Search/Facet/Less']`
  - `snippets['Search/Facet/All']`
  - `resx.Facet_Rating_And_Up`

- **JavaScript:**
  - Facet interaction handlers
  - Show more/less toggle
  - Filter application logic

## Change History
- Comprehensive facet type support (4 types)
- ARIA accessibility implementation
- Show more/less expandable lists
- Star rating visualization
- Multi-select and single-select patterns
- Hit count display
- Currently disabled with `d-none` class
- Keyboard navigation support
