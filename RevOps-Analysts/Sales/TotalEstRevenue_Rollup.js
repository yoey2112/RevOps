function TotalEstRevenue(executionContext) {
    var formContext = executionContext.getFormContext();
    var opportunityId = formContext.data.entity.getId().replace(/[{}]/g, ""); // Remove curly braces from the ID

    if (!opportunityId) {
        console.log('Opportunity ID not found.');
        return;
    }

    // Construct the request URL
    var requestUrl = Xrm.Utility.getGlobalContext().getClientUrl() + "/api/data/v9.0/CalculateRollupField(Target=@tid,FieldName=@fn)?@tid={'@odata.id':'opportunities(" + opportunityId + ")'}&@fn='revops_totalestrevenue'";

    // Call the CalculateRollupField function
    var req = new XMLHttpRequest();
    req.open("GET", requestUrl, true); // Using GET method and asynchronous request
    req.setRequestHeader("Accept", "application/json");
    req.setRequestHeader("OData-MaxVersion", "4.0");
    req.setRequestHeader("OData-Version", "4.0");

    req.onreadystatechange = function () {
        if (this.readyState === 4) {
            req.onreadystatechange = null;
            if (this.status === 200) {
                console.log("Rollup field calculation triggered successfully.");
                formContext.data.refresh(true).then(
                    function success() {
                        console.log("Form data refreshed successfully.");
                    },
                    function error() {
                        console.log("Error refreshing form data.");
                    }
                );
            } else {
                var error = JSON.parse(this.response).error;
                console.log("Error triggering rollup field calculation: " + error.message);
            }
        }
    };

    req.send();
}


