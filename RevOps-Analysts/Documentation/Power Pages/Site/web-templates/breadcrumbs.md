# Breadcrumbs Web Template

## Overview
A simple breadcrumb navigation template that displays the hierarchical path to the current page using the site's page structure.

## Location
`c:\RevOps\Power Page Site\.paportal\swdevportal\web-templates\breadcrumbs\`

## Configuration
- **Template Name**: `Breadcrumbs`
- **Input Parameter**: `title` (optional) - Custom title for active breadcrumb, defaults to `page.title`

## Custom Code

### Liquid Template

```liquid
{% assign title = title | default: page.title %}

<ul class="breadcrumb">
  {% for crumb in page.breadcrumbs -%}
    <li class="breadcrumb-item">
      <a href="{{ crumb.url | h }}" title="{{ crumb.title | h }}">
        {{ crumb.title | truncate: 24 | h }}
      </a>
    </li>
  {% endfor -%}
  <li class="breadcrumb-item active">
    {% block activebreadcrumb %}{{ title | h }}{% endblock %}
  </li>
</ul>
```

### Key Features

1. **Hierarchical Navigation:**
   - Loops through `page.breadcrumbs` collection
   - Displays parent pages in order
   - Current page shown as active (non-clickable)

2. **Title Truncation:**
   - Breadcrumb titles truncated to 24 characters
   - Prevents overflow on long page names
   - Full title shown in `title` attribute (tooltip)

3. **Active Breadcrumb:**
   - Last item marked with `.active` class
   - Not a link (semantic HTML)
   - Uses Liquid block for extensibility

4. **HTML Encoding:**
   - All output escaped with `| h` filter
   - Prevents XSS vulnerabilities
   - Titles and URLs sanitized

5. **Customizable Title:**
   - Accepts `title` parameter
   - Falls back to `page.title`
   - Allows override for special cases

6. **Block Template:**
   - `{% block activebreadcrumb %}` allows inheritance
   - Can be overridden in extending templates

## Usage

**Default Usage:**
```liquid
{% include 'Breadcrumbs' %}
```

**Custom Active Title:**
```liquid
{% include 'Breadcrumbs', title: 'Custom Page Name' %}
```

**In Page Template:**
```html
<div class="container">
  {% include 'Breadcrumbs' %}
  <!-- Page content -->
</div>
```

### Example Output

**HTML:**
```html
<ul class="breadcrumb">
  <li class="breadcrumb-item">
    <a href="/" title="Home">Home</a>
  </li>
  <li class="breadcrumb-item">
    <a href="/knowledge-base" title="Knowledge Base">Knowledge Base</a>
  </li>
  <li class="breadcrumb-item">
    <a href="/knowledge-base/products" title="Products & Services">Products & Services</a>
  </li>
  <li class="breadcrumb-item active">Microsoft 365</li>
</ul>
```

**Visual Example:**
```
Home > Knowledge Base > Products & Service... > Microsoft 365
```

## Related Components

- **Bootstrap Classes:**
  - `.breadcrumb` - Bootstrap breadcrumb styling
  - `.breadcrumb-item` - Individual breadcrumb items
  - `.active` - Active/current page styling

- **Page Properties:**
  - `page.breadcrumbs` - Collection of parent pages
  - `page.title` - Current page title

- **CSS Styling:**
  - Bootstrap breadcrumb styles
  - Custom site styling may override

## Change History
- Simple implementation using Bootstrap breadcrumbs
- Title truncation at 24 characters
- HTML encoding for security
- Block template for extensibility
- Optional title parameter
- Tooltip on hover with full title

## Recommendations
- Consider making truncation length configurable (site setting)
- May want to add schema.org BreadcrumbList markup for SEO
- Consider responsive design (hiding intermediate breadcrumbs on mobile)
