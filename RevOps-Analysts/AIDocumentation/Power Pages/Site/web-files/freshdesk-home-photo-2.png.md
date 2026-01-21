# freshdesk-home-photo-2.png - Homepage Feature Image

## Overview
PNG image asset used on the portal homepage, likely related to support or helpdesk functionality. The "freshdesk" reference suggests this image may be associated with customer support features or help center sections.

## Location
`/web-files/freshdesk-home-photo-2.png`
- **Web File ID**: 74e3e473-fed0-4c44-a4c0-e3cb2201f394
- **Parent Page ID**: 60419c17-9d55-4eb3-b9d8-a0f182dc38e2
- **Partial URL**: freshdesk-home-photo-2.png
- **MIME Type**: image/png

## Configuration
- **Publishing State**: Published (81c6631c-ca6b-4b35-8228-8e759104c26e)
- **Excluded from Search**: No
- **Hidden from Sitemap**: No
- **Tracking Enabled**: No
- **Summary**: (empty)
- **Title**: (empty)

## Technical Specifications
- **Format**: PNG (supports transparency, better for graphics/illustrations)
- **Naming**: "-2" suffix suggests part of a series or version 2
- **Purpose**: Homepage visual content

## Likely Usage Scenarios

### Homepage Hero Section
```html
<section class="section-landing">
  <div class="container">
    <div class="row">
      <div class="col-md-6">
        <h1>Welcome to Support</h1>
        <p>Get the help you need</p>
      </div>
      <div class="col-md-6">
        <img src="/freshdesk-home-photo-2.png" 
             alt="Customer Support" 
             class="img-responsive">
      </div>
    </div>
  </div>
</section>
```

### Support/Help Section
```html
<section class="section-default">
  <div class="container">
    <h2>Need Help?</h2>
    <img src="/freshdesk-home-photo-2.png" alt="Support Center">
    <p>Our support team is here to assist you.</p>
  </div>
</section>
```

### Feature Highlight
- Support center introduction
- Help desk feature showcase
- Customer service section
- Contact/support call-to-action area

## Context: Freshdesk Integration
The filename suggests potential integration with or inspiration from Freshdesk, a popular customer support platform. This image likely:
- Represents support/help center functionality
- Used in customer support sections
- Part of help/contact page design
- Visual for support ticket system

## CSS Styling Context
```css
.section-search .header-search img {
  max-width: 350px;
}

@media screen and (max-width: 600px) {
  .section-search .header-search h1 {
    font-size: 13vw;
  }
}
```

## Related Sections in Theme

### Section Search Styling
```css
.section-search .header-search {
  padding-top: 40px;
  padding-bottom: 40px;
  margin-bottom: 40px;
  background-color: #eeeeee;
}
```

### Inline Search Section
```css
.section-inline-search {
  background-size: cover;
}
.section-inline-search .row > div {
  margin-top: 100px;
}
```

## Responsive Behavior

### Desktop (≥768px)
- Display alongside text content
- Part of two-column layout
- Full-size display with max-width constraint

### Mobile (<768px)
- Stack vertically with content
- Full-width responsive
- Proportional scaling

## Accessibility
- **Alt Text Required**: Describe the image purpose
- **Context**: Should complement surrounding text
- **Not Sole Information**: Don't rely only on image for critical info

### Example Alt Text
```html
<img src="/freshdesk-home-photo-2.png" 
     alt="Customer support representative assisting a client">
```

## Performance Considerations
- **PNG Format**: Larger than JPEG but supports transparency
- **Optimization**: Ensure image is compressed
- **Lazy Loading**: Consider for below-fold placement
- **Responsive**: Use srcset for different screen sizes

## Usage Locations

### Homepage
- ✅ Primary usage location
- Support section
- Hero or featured area
- Call-to-action section

### Support/Help Pages
- ✅ Help center landing page
- Support documentation
- Contact page
- FAQ sections

### Knowledge Base
- ✅ Related to knowledge base access
- Search functionality
- Help resources

## Related Components
- **Search web templates**: Search page layouts
- **Homepage web templates**: Home page sections
- **Help/Support pages**: Support documentation pages
- **theme.css**: Section and image styling

## Image Content (Likely)
Based on the filename and context, this image probably contains:
- Customer support imagery
- Help desk illustration
- Support team photos
- Technology/portal interface visuals
- Professional service imagery

## Brand Consistency
- Should align with Sherweb brand guidelines
- Consistent with other portal imagery
- Professional appearance
- Supports portal's customer service focus

## Implementation Example
```html
<!-- Homepage support section -->
<section class="section-diagonal-right">
  <div class="section-diagonal-right-content">
    <div class="container">
      <div class="row">
        <div class="col-md-6">
          <h2>24/7 Support</h2>
          <p>Our dedicated support team is always here to help you succeed.</p>
          <a href="/support" class="btn btn-primary">Get Support</a>
        </div>
        <div class="col-md-6">
          <img src="/freshdesk-home-photo-2.png" 
               alt="24/7 Customer Support Team" 
               class="img-responsive">
        </div>
      </div>
    </div>
  </div>
</section>
```

## File Management
- **Version Control**: "-2" suggests multiple versions exist
- **Updates**: Can be updated without changing filename
- **Consistency**: Maintain visual style across updates

## SEO Impact
- **Not Excluded from Search**: Indexed by search engines
- **Alt Text Important**: Contributes to image SEO
- **Context**: Surrounding text provides context to search engines

## Change History
- PNG format for quality and transparency support
- Version 2 indicated by "-2" suffix
- Published and searchable
- Homepage feature image for support/help sections
