// Adjust field visibility based on selected request type
function fieldvisibility(executionContext) {
    var formContext = executionContext.getFormContext(); // Correctly assign formContext
    console.log(executionContext);

    var requesttypeAttribute = formContext.data.entity.attributes.get("revops_pricingrequesttype");
    console.log(requesttypeAttribute.getValue());

    // Pricing Request
    if (requesttypeAttribute.getValue() === 234570000) {
        formContext.getControl("revops_discount").setVisible(true);
        formContext.getControl("revops_netamountrequested").setVisible(false);
        formContext.getControl("revops_ticketnumber").setVisible(false);
        formContext.getControl("revops_reason").setVisible(false);
        formContext.getControl("revops_seatplanbreakdown").setVisible(true);
        formContext.getControl("revops_currentprices").setVisible(true);
        formContext.getControl("revops_currentsolutionprovider").setVisible(true);
    }
    // Credit Request
    else if (requesttypeAttribute.getValue() === 234570001) {
        formContext.getControl("revops_discount").setVisible(false);
        formContext.getControl("revops_seatplanbreakdown").setVisible(false);
        formContext.getControl("revops_currentprices").setVisible(false);
        formContext.getControl("revops_currentsolutionprovider").setVisible(false);
        formContext.getControl("revops_netamountrequested").setVisible(true);
        formContext.getControl("revops_ticketnumber").setVisible(true);
        formContext.getControl("revops_reason").setVisible(true);
    }
}