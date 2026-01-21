// Take form fields and concatenate UTM Link
function concatenateUTMLink(executionContext) {
    try {
        // Get form context
        var formContext = executionContext.getFormContext();

        // Get the values from the "campaign", "url", "utmmedium", "utmsource", "utmterm", and "utmcontent" fields
        var campaignAttribute = formContext.data.entity.attributes.get("revops_parentcampaignid");
        var urlAttribute = formContext.data.entity.attributes.get("revops_url");
        var mediumAttribute = formContext.data.entity.attributes.get("revops_utmmedium");
        var sourceAttribute = formContext.data.entity.attributes.get("revops_utmsource");
        var utmTermAttribute = formContext.data.entity.attributes.get("revops_utmterm");
        var utmContentAttribute = formContext.data.entity.attributes.get("revops_utmcontent");

        // Log the entire campaignAttribute object to the console
        console.log("Campaign Attribute:", campaignAttribute);

        // Check if the "campaign" attribute is available and has a value
        if (campaignAttribute && campaignAttribute.getValue()) {
            // Extract the name or any other relevant information from the lookup field object
            var campaignValue = campaignAttribute.getValue()[0];

            // Log the entire campaignValue object to the console
            console.log("Campaign Value:", campaignValue);

            // Ensure campaignValue is not null or undefined
            if (campaignValue) {
                // Retrieve the GUID and name of the current record (Campaign)
                var campaignId = campaignValue.id.replace(/[{}]/g, '').toLowerCase();
                var campaignName = campaignValue.name.replace(/[{}]/g, '').toLowerCase();

                // Get values of "utmmedium", "utmsource", "utmterm", and "utmcontent"
                var mediumOptions = mediumAttribute.getOptions();
                var sourceOptions = sourceAttribute.getOptions();
                var utmTermValue = utmTermAttribute.getValue();
                var utmContentValue = utmContentAttribute.getValue();

                // Find the text value for "utmmedium" and "utmsource" based on the selected values
                var mediumText = findOptionText(mediumOptions, mediumAttribute.getValue()).toLowerCase();
                var sourceText = findOptionText(sourceOptions, sourceAttribute.getValue()).toLowerCase();
                var utmTermText = utmTermValue ? utmTermValue.toLowerCase() : "";
                var utmContentText = utmContentValue ? utmContentValue.toLowerCase() : "";

                // Replace spaces with underscores
                mediumText = mediumText.replace(/\s/g, "_");
                sourceText = sourceText.replace(/\s/g, "_");
                utmTermText = utmTermText.replace(/\s/g, "_");
                utmContentText = utmContentText.replace(/\s/g, "_");
                campaignName = campaignName.replace(/\s/g, "_");

                // Get the value from the "url" field
                var urlValue = urlAttribute.getValue();

                // Check if the URL starts with "https://", if not, add it
                if (urlValue && !urlValue.startsWith("https://")) {
                    urlValue = "https://" + urlValue;
                }

                // Build the UTM link with additional parameters
                var utmLinkValue = urlValue +
                    "/?utm_campaign=" + encodeURIComponent(campaignName) +
                    "&utm_campaignid=" + campaignId +
                    "&utm_medium=" + (mediumAttribute.getValue() === 234570004 ? "cpc" : encodeURIComponent(mediumText)) +
                    "&utm_source=" + encodeURIComponent(sourceText) +
                    (utmTermText ? "&utm_term=" + encodeURIComponent(utmTermText) : "") +
                    (utmContentText ? "&utm_content=" + encodeURIComponent(utmContentText) : "");

                // Concatenate "campaign - Medium - Source" and set the value to the new field
                var campaignMediumSource = campaignName + " - " + mediumText + " - " + sourceText;
                formContext.data.entity.attributes.get("revops_name").setValue(campaignMediumSource);    

                // Set the concatenated value to the "utm_link" field
                formContext.data.entity.attributes.get("revops_utmlink").setValue(utmLinkValue);

                // Use campaignId, campaignName, mediumText, sourceText, utmTermText, utmContentText as needed
                console.log("Campaign GUID: " + campaignId);
                console.log("Campaign Name: " + campaignName);
                console.log("Medium Text: " + mediumText);
                console.log("Source Text: " + sourceText);
                console.log("UTM Term Text: " + utmTermText);
                console.log("UTM Content Text: " + utmContentText);
            }
        } else {
            // Handle the case when the "campaign" attribute is not found or is empty
            formContext.data.entity.attributes.get("revops_utmlink").setValue("");
            console.log("No Campaign selected");
        }
    } catch (error) {
        console.error("An error occurred: " + error.message);
    }
}

function findOptionText(options, selectedValue) {
    var selectedOption = options.find(function (option) {
        return option.value === selectedValue;
    });

    return selectedOption ? selectedOption.text : "";
}

// Filter Source choices based on selected Medium
function filterSource(executionContext) {
    var formContext = executionContext.getFormContext();
    var mediumAttribute = formContext.data.entity.attributes.get("revops_utmmedium");
    var sourceControl = formContext.getControl("revops_utmsource");

    sourceControl.clearOptions();

    // Referral
    if (mediumAttribute.getValue() === 234570000) {

        sourceControl.addOption({ text: "PDF", value: 234570002 });
        sourceControl.addOption({ text: "Cumulus", value: 234570019 });
        sourceControl.addOption({ text: "Beamer", value: 234570020 });
    }
    // Email
    else if (mediumAttribute.getValue() === 234570002) {
        sourceControl.addOption({ text: "Email", value: 234570016 });
    }
    // Organic
    else if (mediumAttribute.getValue() === 234570003) {
        sourceControl.addOption({ text: "Google", value: 234570006 });
        sourceControl.addOption({ text: "Bing", value: 234570012 });
    }
    // CPC
    else if (mediumAttribute.getValue() === 234570004) {
        sourceControl.addOption({ text: "Google", value: 234570006 });
        sourceControl.addOption({ text: "Bing", value: 234570012 });
        sourceControl.addOption({ text: "Facebook", value: 234570014 });
        sourceControl.addOption({ text: "Reddit", value: 234570015 });
        sourceControl.addOption({ text: "LinkedIn", value: 234570013 });
        sourceControl.addOption({ text: "Twitter", value: 234570018 });
        sourceControl.addOption({ text: "Community", value: 234570017 });

    }
    // Social
    else if (mediumAttribute.getValue() === 234570005) {
        sourceControl.addOption({ text: "LinkedIn", value: 234570013 });
        sourceControl.addOption({ text: "Facebook", value: 234570014 });
        sourceControl.addOption({ text: "Youtube", value: 234570011 });
        sourceControl.addOption({ text: "Reddit", value: 234570015 });
        sourceControl.addOption({ text: "Twitter", value: 234570018 });
        sourceControl.addOption({ text: "Community", value: 234570017 });


    }
}

// Button to copy UTM Link
function copyToClipboard() {
    var textFieldValue = Xrm.Page.getAttribute("revops_utmlink").getValue();
    if (textFieldValue) {
        var dummyElement = document.createElement("textarea");
        document.body.appendChild(dummyElement);
        dummyElement.value = textFieldValue;
        dummyElement.select();
        document.execCommand("copy");
        document.body.removeChild(dummyElement);
    }
}