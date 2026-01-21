# KB Category Widget Web Template

## Overview
A comprehensive knowledge base category widget that displays hierarchical categories with their associated articles. Supports both top-level category view and filtered subcategory view with article counts and navigation.

## Location
`c:\RevOps\Power Page Site\.paportal\swdevportal\web-templates\kbcategorywidget\`

## Configuration
- **Template ID**: `f4e257c0-d54d-f011-877b-6045bd5e3f6b`
- **Template Name**: `KBCategoryWidget`
- **Language**: English (United States)
- **Language Locale ID**: `{56940b3e-300f-4070-a559-5a6a4d11a8a3}`

## Custom Code

### Input Parameters
```liquid
{% assign input_category = input_category | default: '' %}
```

### FetchXML Queries

**1. Articles Query:**
```xml
<fetch aggregate="true" returntotalrecordcount="true">
  <entity name="knowledgearticle">
    <attribute name="knowledgearticleid" alias="knowledgearticleid" groupby="true" />
    <attribute name="title" alias="title" groupby="true" />
    <attribute name="statecode" alias="statecode" groupby="true" />
    <attribute name="statuscode" alias="statuscode" groupby="true" />
    <attribute name="revops_category" alias="categoryid" groupby="true" />
    <attribute name="articlepublicnumber" alias="articlepublicnumber" groupby="true" />
    <filter type="and">
      <condition attribute="statecode" operator="eq" value="3" /> <!-- Published -->
      <condition attribute="isrootarticle" operator="eq" value="0" />
      <condition attribute="isinternal" operator="eq" value="0" />
      <condition attribute="languagelocaleid" operator="eq" value="{56940b3e-300f-4070-a559-5a6a4d11a8a3}" />
    </filter>
    <order alias="title" />
    <link-entity name="category" alias="aa" link-type="inner" from="categoryid" to="revops_category">
      <attribute name="title" alias="category" groupby="true" />
      <filter type="and">
        <condition attribute="title" operator="not-null" />
      </filter>
    </link-entity>
  </entity>
</fetch>
```

**2. Categories Query:**
```xml
<fetch aggregate="true">
  <entity name="category">
    <attribute name="title" alias="title" groupby="true" />
    <attribute name="categoryid" alias="categoryid" groupby="true" />
    <attribute name="categorynumber" alias="categorynumber" groupby="true" />
    <attribute name="parentcategoryid" alias="parentcategoryid" groupby="true" />
    <attribute name="revops_istoplevelcategory" alias="istoplevelcategory" groupby="true" />
    <attribute name="revops_isinternal" alias="isinternal" groupby="true" />
    <filter type="and">
      <condition attribute="title" operator="not-null" />
    </filter>
    <order alias="title" />
    <link-entity name="category" alias="parent" link-type="outer" from="categoryid" to="parentcategoryid">
      <attribute name="title" alias="parenttitle" groupby="true" />
      <attribute name="categoryid" alias="parentcategoryid_value" groupby="true" />
    </link-entity>
  </entity>
</fetch>
```

### Data Processing

**Filters:**
```liquid
{% assign categories = categoriesQuery.results.entities | where: "isinternal", false %}
{% assign articles = articlesQuery.results.entities %}
{% assign top_level_categories = categories | where: "istoplevelcategory", true %}
```

### Display Logic

**Mode 1: Filtered by Input Category**
```liquid
{% if input_category != '' %}
  {% assign subcategories = categories | where: "parenttitle", input_category %}
  <!-- Display subcategories under the specified parent -->
{% endif %}
```

**Mode 2: Full Hierarchy View**
```liquid
{% else %}
  {% for top_category in top_level_categories %}
    <!-- Display all top-level categories with their subcategories -->
  {% endfor %}
{% endif %}
```

### HTML Structure

**Category Block:**
```html
<div class="col-12 col-md-6">
  <div class="category-block">
    <h4 class="fw-normal pb-0 d-flex align-items-center">
      {{ category.title }}
      <span class="badge rounded-pill bg-danger ms-2">{{ category_articles.size }}</span>
    </h4>
    <ul class="list-group list-group-flush">
      {% for article in category_articles limit:5 %}
        <li class="list-group-item">
          <a href="{{ article.url | escape }}" class="d-flex gap-3 align-items-center">
            <i class="fa-light fa-file"></i><span>{{ article.title }}</span>
          </a>
        </li>
      {% endfor %}
    </ul>
    <a href="{{ category_url | add_query: 'id', category.categorynumber }}" 
       class="btn btn-outline-secondary btn-sm">
      See all articles
    </a>
  </div>
</div>
```

### Key Features

1. **Hierarchical Category Display:**
   - Top-level categories identified by `revops_istoplevelcategory` flag
   - Parent-child relationships via `parentcategoryid`
   - Filtering of internal categories

2. **Article Association:**
   - Aggregated query for performance
   - Article counts displayed in badges
   - Limited to 5 articles per category preview

3. **Dynamic Navigation:**
   - "See all articles" links to category detail pages
   - Category number used as query parameter
   - Uses site marker 'Category' for URL construction

4. **Empty State Handling:**
   - "No subcategories found" message
   - "No articles found in subcategories" message
   - Conditional rendering based on article availability

5. **Duplicate Prevention:**
   - `processed_categories` array to track rendered categories
   - Case-insensitive GUID comparison

6. **Responsive Layout:**
   - Bootstrap grid: `col-12 col-md-6` (2-column on medium+)
   - `col-12 col-md-5` variant for specific layouts
   - Flexible gap spacing

7. **Custom Fields:**
   - `revops_category` - Lookup to category on knowledge article
   - `revops_istoplevelcategory` - Boolean flag on category
   - `revops_isinternal` - Internal category filter

## Usage

**Default View (All Categories):**
```liquid
{% include 'KBCategoryWidget' %}
```

**Filtered View (Specific Category):**
```liquid
{% include 'KBCategoryWidget', input_category: 'Products & Services' %}
```

## Related Components

- **Web Templates:**
  - Knowledge Base page templates
  - Category detail pages
  - Article pages

- **Site Markers:**
  - `Category` - Category detail page URL

- **Entities:**
  - `knowledgearticle` - Published KB articles
  - `category` - KB categories
  - Custom fields on category entity:
    - `revops_category`
    - `revops_istoplevelcategory`
    - `revops_isinternal`

- **Language Locales:**
  - English - United States (`{56940b3e-300f-4070-a559-5a6a4d11a8a3}`)

## Change History
- Implemented hierarchical category structure
- Added article count badges
- Limited article preview to 5 items per category
- Added duplicate category prevention logic
- Implemented filtering for internal categories
- Added empty state messages
- Bootstrap 5 styling with responsive grid
- FontAwesome Light icons for article items
- Dynamic URL construction with category numbers
