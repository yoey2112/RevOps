# Multistep Case Creation - Advanced Form

## Overview
The "Multistep Case Creation" advanced form is a multistep wizard that guides users through the process of creating a support case. This form provides a structured workflow for case creation, breaking down the process into multiple sequential steps.

## Location
Power Pages Site: `.paportal\swdevportal\advanced-forms\multistep-case-creation\Multistep-Case-Creation.advancedform.yml`

## Configuration

### Basic Settings
- **Web Form ID**: `d2e4cc5a-c10f-45a5-8c0d-6a766f3fc65e`
- **Name**: Multistep Case Creation
- **Start Step ID**: `d0a553be-bb0d-4beb-88d0-d3726bfb9794`

### Form Behavior
- **Edit Existing Record Permitted**: Yes
- **Multiple Records Per User Permitted**: No (users can only have one active case creation session)
- **Progress Indicator Enabled**: No
- **Progress Indicator Position**: Top (756150000)

## Custom Code
No custom JavaScript files are directly associated with this advanced form configuration. Custom logic may exist in the individual step forms.

## Workflow

This advanced form orchestrates a multistep workflow for case creation. The form starts at step `d0a553be-bb0d-4beb-88d0-d3726bfb9794` and progresses through subsequent steps defined in the step configurations.

### Step Configuration
The individual steps are likely configured as basic forms or form steps that are referenced by this advanced form. The steps would typically include:
1. Initial case information collection
2. Case details and description
3. File attachments (if applicable)
4. Review and submit

**Note**: Without the step configuration files visible in the folder, the exact step sequence cannot be documented. The steps are defined in Dataverse and referenced by their GUIDs.

## Usage
This multistep form is used to guide portal users through the case creation process in a structured manner. Users cannot skip steps or create multiple concurrent case creation sessions. The form does not display a progress indicator, suggesting a simplified user experience.

## Related Components
- **Start Step**: Form step with ID `d0a553be-bb0d-4beb-88d0-d3726bfb9794`
- **Entity**: Likely `incident` (case)
- **Basic Forms**: Individual step forms referenced within the workflow
- **Web Pages**: Case creation pages that host this advanced form

## Change History
- Configured as a single-session form (multiple records per user not permitted)
- Progress indicator disabled for simplified UX
- Edit permissions enabled to allow users to modify cases in progress