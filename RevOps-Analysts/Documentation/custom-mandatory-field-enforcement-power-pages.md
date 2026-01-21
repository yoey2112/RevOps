# Mandatory Field Enforcement Guide for Power Pages Forms

## Overview

This guide explains how to implement custom mandatory field validation for Power Pages forms when the built-in required field functionality is insufficient. This solution is necessary because Power Pages strips the `required` attribute from fields that aren't configured as required in the Forms Editor.

## The Problem

- **Power Pages Limitation**: HTML5 `required` attributes are removed from fields not marked as required in the Forms Editor
- **Shared Forms**: When forms are shared across multiple configurations, you can't mark fields as required in the Forms Editor without affecting all uses
- **Button Click Handler**: Power Pages submits forms via button click handlers, not standard form submit events
- **Modal Interference**: Submit buttons in lookup modals trigger form validation incorrectly

## The Solution

Custom JavaScript validation that:
1. Intercepts submit button clicks using capture phase event handlers
2. Validates fields before Power Pages handlers execute
3. Excludes modal submit buttons from validation
4. Provides visual feedback (red asterisks, red borders, alert messages)

---

## AI Assistant Prompt

Use this prompt when working with an AI assistant to implement mandatory field validation on a Power Pages form:

```
I need to implement mandatory field enforcement for a Power Pages form. The form has fields that need to be required, but I cannot mark them as required in the Forms Editor because the form is shared across multiple configurations.

Please implement custom JavaScript validation that:

1. Makes the following fields mandatory: [LIST YOUR FIELD LOGICAL NAMES]
   Example: emailaddress, title, revops_cumulusorganization

2. Adds red asterisks (*) next to required field labels

3. Validates on form submission and:
   - Shows an alert listing all missing required fields
   - Adds red borders to empty required fields
   - Scrolls to and focuses the first error field
   - Prevents form submission if validation fails

4. Excludes submit buttons inside modals (for lookup fields) from triggering validation

5. Handles Power Pages' custom form submission (button click handlers, not form submit events)

Technical requirements:
- Use jQuery (already available in Power Pages)
- Wait for form fields to load before attaching validation
- Use capture phase event listeners to intercept button clicks before Power Pages
- Detect modals using: .modal, .ui-dialog, [role="dialog"], .ms-Overlay
- Field containers use td.clearfix structure in Power Pages

The form name in Power Pages is: [YOUR FORM NAME]
Example: "Create Case - Migration Request"
```

---

## Implementation Steps

### Step 1: Add CSS for Hidden Fields

Add this CSS to your Power Pages page or web template:

```css
<style>
  /* Hidden field styling for Power Pages td.clearfix structure */
  td.clearfix.field-hidden {
    display: none !important;
  }
</style>
```

### Step 2: Add Validation Script

Add this script after your entityform tag:

```html
<script>
(function() {
    'use strict';
    
    // Wait for jQuery to be available
    function waitForJQuery(callback) {
        if (typeof jQuery !== 'undefined') {
            callback();
        } else {
            setTimeout(function() { waitForJQuery(callback); }, 100);
        }
    }
    
    // Wait for form fields to be fully loaded
    function waitForFormFields(callback, maxAttempts = 150) {
        let attempts = 0;
        const interval = setInterval(function() {
            attempts++;
            
            // Check if at least one of your key fields exists
            const $keyField1 = $('#fieldname1, input[name*="fieldname1"]');
            const $keyField2 = $('#fieldname2, input[name*="fieldname2"]');
            
            if ($keyField1.length > 0 || $keyField2.length > 0) {
                clearInterval(interval);
                callback();
            } else if (attempts >= maxAttempts) {
                clearInterval(interval);
                return;
            }
        }, 200);
    }
    
    waitForJQuery(function() {
        waitForFormFields(function() {
            
            // ============================================
            // HELPER FUNCTIONS
            // ============================================
            
            // Set field as required or optional
            function setFieldRequired(fieldName, required) {
                const selectors = [
                    `#${fieldName}`,
                    `[data-attribute="${fieldName}"]`,
                    `[name*="${fieldName}"]`
                ];
                
                let $field = null;
                
                for (let selector of selectors) {
                    $field = $(selector);
                    if ($field.length > 0) break;
                }
                
                if ($field && $field.length > 0) {
                    if (required) {
                        $field.attr('required', 'required');
                        $field.attr('aria-required', 'true');
                    } else {
                        $field.removeAttr('required');
                        $field.removeAttr('aria-required');
                    }
                    
                    // Handle visual asterisk on label
                    const $container = $field.closest('td.clearfix');
                    let $label = $container.find('label').first();
                    
                    if ($label.length === 0) {
                        const fieldId = $field.attr('id');
                        if (fieldId) {
                            $label = $(`label[for="${fieldId}"]`);
                        }
                    }
                    
                    if ($label.length === 0) {
                        $label = $(`label[for="${fieldName}"]`);
                    }
                    
                    if ($label.length === 0) {
                        $label = $field.prev('label');
                    }
                    
                    if ($label.length > 0) {
                        if (required) {
                            if ($label.find('.required').length === 0) {
                                $label.append(' <span class="required" style="color: red; font-weight: bold;" aria-required="true">*</span>');
                            }
                        } else {
                            $label.find('.required').remove();
                        }
                    }
                    
                    return true;
                } else {
                    console.error(`✗ Field NOT FOUND: ${fieldName}`);
                    return false;
                }
            }
            
            // ============================================
            // FIELD CONFIGURATION
            // ============================================
            
            // List of fields that must be mandatory
            const mandatoryFields = [
                'emailaddress',
                'title',
                'revops_cumulusorganization'
                // Add your field logical names here
            ];
            
            // Set all mandatory fields as required
            mandatoryFields.forEach(function(fieldName) {
                setFieldRequired(fieldName, true);
            });
            
            // ============================================
            // CUSTOM FORM VALIDATION
            // ============================================
            
            function validateForm(e) {
                let hasErrors = false;
                const errors = [];
                
                // Check all mandatory fields
                mandatoryFields.forEach(function(fieldName) {
                    let $field = $(`#${fieldName}`);
                    if ($field.length === 0) {
                        $field = $(`[name*="${fieldName}"]`);
                    }
                    
                    if ($field.length > 0) {
                        const value = $field.val();
                        const isEmpty = !value || value === '' || value === null;
                        
                        if (isEmpty) {
                            hasErrors = true;
                            const $container = $field.closest('td.clearfix');
                            const $label = $container.find('label').first();
                            const labelText = $label.length > 0 ? $label.text().replace('*', '').trim() : fieldName;
                            errors.push(labelText);
                            $field.css('border', '2px solid red');
                        } else {
                            $field.css('border', '');
                        }
                    }
                });
                
                if (hasErrors) {
                    e.preventDefault();
                    e.stopPropagation();
                    
                    const errorMessage = `Please fill in the following required fields:\n\n${errors.join('\n')}`;
                    alert(errorMessage);
                    
                    const $firstErrorField = $('input[style*="border: 2px solid red"], select[style*="border: 2px solid red"], textarea[style*="border: 2px solid red"]').first();
                    if ($firstErrorField.length > 0) {
                        $firstErrorField[0].scrollIntoView({ behavior: 'smooth', block: 'center' });
                        $firstErrorField.focus();
                    }
                    
                    return false;
                }
                
                return true;
            }
            
            // ============================================
            // ATTACH VALIDATION
            // ============================================
            
            // Attach to form submit event
            const $forms = $('form');
            
            $forms.each(function(index) {
                const form = this;
                
                $(form).on('submit', function(e) {
                    return validateForm(e);
                });
                
                form.addEventListener('submit', function(e) {
                    return validateForm(e);
                }, true);
            });
            
            // ============================================
            // INTERCEPT SUBMIT BUTTON CLICKS
            // ============================================
            
            const $submitButtons = $('button[type="submit"], input[type="submit"], .submit-button, button.button-primary, .button-primary, #InsertButton, #UpdateButton, button.btn-primary');
            
            $submitButtons.each(function(index) {
                const button = this;
                
                button.addEventListener('click', function(e) {
                    // Check if button is inside a modal
                    const $button = $(button);
                    const isInModal = $button.closest('.modal, .ui-dialog, [role="dialog"], .ms-Overlay').length > 0;
                    
                    if (isInModal) {
                        return; // Skip validation for modal buttons
                    }
                    
                    // Run validation for main form submit button
                    const isValid = validateForm(e);
                    
                    if (!isValid) {
                        e.preventDefault();
                        e.stopPropagation();
                        e.stopImmediatePropagation();
                        return false;
                    }
                }, true); // true = capture phase (runs first)
            });
            
        }); // End waitForFormFields
    }); // End waitForJQuery
    
})();
</script>
```

---

## Customization Guide

### Adding/Removing Mandatory Fields

Modify the `mandatoryFields` array:

```javascript
const mandatoryFields = [
    'emailaddress',        // Standard Dynamics field
    'title',               // Standard Dynamics field
    'revops_customfield',  // Custom field with revops_ prefix
    'new_anotherfield'     // Custom field with new_ prefix
];
```

### Conditional Mandatory Fields

For fields that should only be mandatory under certain conditions:

```javascript
// Example: Make field mandatory only when another field has a specific value
function handleConditionalField() {
    const $triggerField = $('#revops_triggerfield');
    const triggerValue = $triggerField.val();
    
    if (triggerValue === 'specificvalue') {
        setFieldRequired('revops_conditionalfield', true);
    } else {
        setFieldRequired('revops_conditionalfield', false);
    }
}

// Call on load and when trigger field changes
if ($('#revops_triggerfield').length > 0) {
    handleConditionalField();
    $('#revops_triggerfield').on('change', handleConditionalField);
}
```

### Hiding Fields

To hide fields dynamically:

```javascript
// Add this helper function to your script
function hideField(fieldName) {
    const selectors = [
        `#${fieldName}`,
        `[data-attribute="${fieldName}"]`,
        `[name*="${fieldName}"]`
    ];
    
    for (let selector of selectors) {
        const $field = $(selector);
        if ($field.length > 0) {
            const $container = $field.closest('td.clearfix');
            if ($container && $container.length > 0) {
                $container.addClass('field-hidden');
                return true;
            }
        }
    }
    return false;
}

// Usage
hideField('revops_fieldtohide');
```

### Targeting Specific Submit Buttons

If you have multiple submit buttons and only want validation on specific ones, you can target them more precisely:

```javascript
// Option 1: Target by ID
const $submitButtons = $('#InsertButton, #UpdateButton');

// Option 2: Target by text content
const $submitButtons = $('button[type="submit"]').filter(function() {
    return $(this).text().trim() === 'Submit' || $(this).text().trim() === 'Save';
});

// Option 3: Target by class
const $submitButtons = $('.primary-form-submit, .main-submit-button');

// Option 4: Exclude specific buttons
const $submitButtons = $('button[type="submit"]').not('.modal-submit, .secondary-action');

// Option 5: Target buttons within specific form
const $submitButtons = $('#entityFormControl button[type="submit"]');

// Option 6: Combine multiple conditions
const $submitButtons = $('button[type="submit"]').filter(function() {
    const $btn = $(this);
    // Must not be in a modal
    const isInModal = $btn.closest('.modal, .ui-dialog').length > 0;
    // Must have specific class or ID
    const isMainSubmit = $btn.hasClass('button-primary') || $btn.attr('id') === 'InsertButton';
    return !isInModal && isMainSubmit;
});
```

**Example: Only validate the main form submit button**

```javascript
// Find the main form submit button (usually #InsertButton or #UpdateButton)
const $mainSubmitButton = $('#InsertButton, #UpdateButton').first();

if ($mainSubmitButton.length > 0) {
    $mainSubmitButton[0].addEventListener('click', function(e) {
        const isValid = validateForm(e);
        
        if (!isValid) {
            e.preventDefault();
            e.stopPropagation();
            e.stopImmediatePropagation();
            return false;
        }
    }, true);
} else {
    console.warn('Main submit button not found - falling back to generic selector');
    // Fallback to generic selector if specific button not found
    const $fallbackButtons = $('button[type="submit"]').not('[data-dismiss]');
    $fallbackButtons.each(function() {
        // ... attach validation
    });
}
```

**Example: Validate only non-modal submit buttons**

```javascript
const $submitButtons = $('button[type="submit"], input[type="submit"]');

$submitButtons.each(function() {
    const button = this;
    
    button.addEventListener('click', function(e) {
        const $button = $(button);
        
        // Skip if button is in a modal
        const isInModal = $button.closest('.modal, .ui-dialog, [role="dialog"]').length > 0;
        if (isInModal) {
            return true; // Allow modal buttons to work normally
        }
        
        // Skip if button has data-dismiss or data-cancel attribute
        if ($button.attr('data-dismiss') || $button.attr('data-cancel')) {
            return true;
        }
        
        // Run validation for main form submit buttons only
        const isValid = validateForm(e);
        
        if (!isValid) {
            e.preventDefault();
            e.stopPropagation();
            e.stopImmediatePropagation();
            return false;
        }
    }, true);
});
```

---

## Advanced: Show/Hide Fields Based on Selection

Example: Show fields only when "Yes" is selected in a Yes/No field:

```javascript
const $yesNoField = $('input[name*="revops_yesnofield"]');

function handleYesNoChange() {
    const selectedValue = $yesNoField.filter(':checked').val();
    const isYes = selectedValue === '1' || selectedValue === 'true' || selectedValue === '100000000';
    
    if (isYes) {
        // Show fields
        toggleField('revops_dependentfield1', true);
        toggleField('revops_dependentfield2', true);
        
        // Make them mandatory
        setFieldRequired('revops_dependentfield1', true);
        setFieldRequired('revops_dependentfield2', true);
    } else {
        // Hide fields
        toggleField('revops_dependentfield1', false);
        toggleField('revops_dependentfield2', false);
        
        // Make them optional
        setFieldRequired('revops_dependentfield1', false);
        setFieldRequired('revops_dependentfield2', false);
    }
}

// Add toggleField helper function
function toggleField(fieldName, show) {
    let $field = $(`#${fieldName}`);
    
    if ($field.length === 0) {
        $field = $(`[data-attribute="${fieldName}"]`);
    }
    
    if ($field.length === 0) {
        $field = $(`[name*="${fieldName}"]`);
    }
    
    if ($field.length > 0) {
        const $container = $field.closest('td.clearfix');
        
        if ($container && $container.length > 0) {
            if (show) {
                $container.removeClass('field-hidden');
            } else {
                $container.addClass('field-hidden');
            }
            return true;
        }
    }
    return false;
}

if ($yesNoField.length > 0) {
    handleYesNoChange(); // Run on load
    $yesNoField.on('change', handleYesNoChange); // Run on change
}
```

---

## Troubleshooting

### Fields Not Being Found

If fields aren't being found, check the console for error messages:
```
✗ Field NOT FOUND: fieldname
```

**Solutions:**
1. Verify the field logical name in Power Apps
2. Check if the field is on the form in the Forms Editor
3. Try alternate selectors:
   ```javascript
   const $field = $('#fieldname, [data-attribute="fieldname"], [name*="fieldname"]');
   console.log('Field found:', $field.length > 0);
   ```

### Form Still Submits with Empty Fields

**Cause**: Power Pages button click handler is executing before our validation.

**Solution**: Ensure you're using capture phase (`true` parameter):
```javascript
button.addEventListener('click', function(e) {
    // validation code
}, true); // ← This must be true
```

### Modal Submit Buttons Trigger Validation

**Cause**: Modal buttons are not being detected.

**Solution**: Add more modal selectors:
```javascript
const isInModal = $button.closest('.modal, .ui-dialog, [role="dialog"], .ms-Overlay, .ms-Dialog, [role="alertdialog"]').length > 0;
```

### Validation Not Running

**Cause**: Form fields may not have loaded before script executes.

**Solution**: Increase `maxAttempts` in `waitForFormFields`:
```javascript
function waitForFormFields(callback, maxAttempts = 200) { // Increased from 150
    // ... rest of code
}
```

---

## Testing Checklist

- [ ] Load form - verify red asterisks appear on required fields
- [ ] Leave required fields empty and click Submit
- [ ] Verify alert appears listing missing fields
- [ ] Verify red borders appear on empty required fields
- [ ] Verify page scrolls to first error field
- [ ] Fill all required fields and submit - should succeed
- [ ] Test lookup field modals - verify modal submit buttons don't trigger validation
- [ ] Test conditional logic (if applicable)
- [ ] Test on different browsers (Chrome, Edge, Firefox)

---

## Related Patterns

### Pattern: Auto-populate Fields

```javascript
// Example: Auto-populate queue field from Liquid query
const queueId = window.MIGRATION_QUEUE_ID;
const queueName = window.MIGRATION_QUEUE_NAME;

function setLookupField(fieldId, entityName, recordId, recordName) {
    const field = $(`#${fieldId}`);
    
    if (field.length && recordId) {
        field.val(recordId);
        field.attr('value', recordId);
        
        const entityNameField = $(`#${fieldId}_entityname`);
        const nameField = $(`#${fieldId}_name`);
        
        if (entityNameField.length) {
            entityNameField.val(entityName);
        }
        
        if (nameField.length) {
            nameField.val(recordName);
        }
        
        field.trigger('change');
        return true;
    }
    return false;
}

setLookupField('revops_queue', 'queue', queueId, queueName);
```

---

## Best Practices

1. **Keep mandatory field list updated**: Document which fields are required
2. **Use meaningful error messages**: Display field labels, not logical names
3. **Test thoroughly**: Validate on different screen sizes and browsers
4. **Consider accessibility**: Red asterisks include `aria-required="true"`
5. **Remove debug logging**: Clean up console.log statements in production
6. **Document dependencies**: Note if validation depends on other scripts
7. **Version control**: Keep validation logic in version control
8. **Comment your code**: Explain why fields are mandatory or conditional

---

## Additional Resources

- [Power Pages Documentation](https://learn.microsoft.com/en-us/power-pages/)
- [jQuery Documentation](https://api.jquery.com/)
- [MDN: Event.stopImmediatePropagation()](https://developer.mozilla.org/en-US/docs/Web/API/Event/stopImmediatePropagation)
- [ARIA: required attribute](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-required)

---

## Version History

- **v1.0** (2025-11-19): Initial documentation
  - Basic mandatory field enforcement
  - Modal button exclusion
  - Conditional field logic examples
  - Troubleshooting guide

---

## Support

If you encounter issues:
1. Check the console for error messages
2. Verify field logical names in Power Apps
3. Test field detection with alternate selectors
4. Review the troubleshooting section above
5. Check that jQuery is available: `console.log(typeof jQuery)`
