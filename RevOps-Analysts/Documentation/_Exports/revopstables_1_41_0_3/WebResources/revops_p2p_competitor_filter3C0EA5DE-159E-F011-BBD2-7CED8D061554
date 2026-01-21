// revops_/js/competitorFilter_dynamic.js
(function () {
  var CASE_COMPETITOR_REGION_ATTR = "revops_competitorregion";
  var CASE_LOSING_COMPETITOR_CTRL = "revops_losingcompetitor";

  var CTID_ENTITY          = "revops_competitortransferid";
  var CTID_COMPETITOR_ATTR = "revops_competitor";
  var CTID_REGION_ATTR     = "revops_region";
  var CTID_TYPE_ATTR       = "revops_transfertype";
  var MICROSOFT_VALUE      = 234570000;

  var COMPETITOR_ENTITY    = "competitor";
  var REGION_ENTITY        = "msdyn_region";

  var VIEW_ID   = "11111111-2222-4333-8444-555555555555";
  var VIEW_NAME = "Competitors (Microsoft) for selected Region";

  function braced(id) { id = String(id || ""); return id.startsWith("{") ? id : "{" + id + "}"; }
  function strip(id)  { return String(id || "").replace(/[{}]/g, ""); }

  function buildFetchXml(regionId) {
    var regionIdBraced = braced(regionId);
    return (
      "<fetch version='1.0' mapping='logical' distinct='true'>" +
        "<entity name='" + COMPETITOR_ENTITY + "'>" +
          "<attribute name='competitorid' />" +
          "<attribute name='name' />" +
          "<order attribute='name' ascending='true' />" +
          "<link-entity name='" + CTID_ENTITY + "' from='" + CTID_COMPETITOR_ATTR + "' to='competitorid' link-type='inner' alias='ctid'>" +
            "<filter type='and'>" +
              "<condition attribute='statecode' operator='eq' value='0' />" +
              "<condition attribute='" + CTID_REGION_ATTR + "' operator='eq' uitype='" + REGION_ENTITY + "' value='" + regionIdBraced + "' />" +
              "<condition attribute='" + CTID_TYPE_ATTR + "' operator='contain-values'>" +
                "<value>" + MICROSOFT_VALUE + "</value>" +
              "</condition>" +
            "</filter>" +
          "</link-entity>" +
        "</entity>" +
      "</fetch>"
    );
  }

  function buildLayoutXml() {
    return "" +
      "<grid name='resultset' jump='name' select='1' icon='1' preview='0'>" +
        "<row name='result' id='competitorid'>" +
          "<cell name='name' width='300' />" +
        "</row>" +
      "</grid>";
  }

  function applyCompetitorView(formContext) {
    var regionAttr = formContext.getAttribute(CASE_COMPETITOR_REGION_ATTR);
    var compCtrl   = formContext.getControl(CASE_LOSING_COMPETITOR_CTRL);
    if (!regionAttr || !compCtrl) return;

    var regionVal = regionAttr.getValue();
    if (!Array.isArray(regionVal) || !regionVal.length) return;

    var regionId   = strip(regionVal[0].id);
    var fetchXml   = buildFetchXml(regionId);
    var layoutXml  = buildLayoutXml();

    try {
      compCtrl.addCustomView(VIEW_ID, COMPETITOR_ENTITY, VIEW_NAME, fetchXml, layoutXml, true);
      if (typeof compCtrl.setDefaultView === "function") compCtrl.setDefaultView(VIEW_ID);
      var attr = formContext.getAttribute(CASE_LOSING_COMPETITOR_CTRL);
      if (attr) attr.setValue(null);
    } catch (e) {
      console.warn("[competitorFilter] addCustomView failed:", e && e.message ? e.message : e);
    }
  }

  function wirePreSearch(formContext) {
    var compCtrl = formContext.getControl(CASE_LOSING_COMPETITOR_CTRL);
    if (!compCtrl) return;
    try { compCtrl.removePreSearch(); } catch (_) {}
    compCtrl.addPreSearch(function () { applyCompetitorView(formContext); });
  }

  // --- Wait for Competitor Region before applying ---
  function waitForRegionAndApply(formContext, retries) {
    retries = retries || 0;
    var regionAttr = formContext.getAttribute(CASE_COMPETITOR_REGION_ATTR);
    var val = regionAttr && regionAttr.getValue();

    if (val && val.length) {
      applyCompetitorView(formContext);
    } else if (retries < 20) { // retry up to 20 times (≈4s total if 200ms)
      setTimeout(function () {
        waitForRegionAndApply(formContext, retries + 1);
      }, 200);
    } else {
      console.warn("[competitorFilter] Region not set after waiting.");
    }
  }

  // Public handlers
  function onLoad(executionContext) {
    var fc = executionContext.getFormContext();
    wirePreSearch(fc);
    waitForRegionAndApply(fc); // <-- waits until Region is populated
  }

  function onRegionChange(executionContext) {
    var fc = executionContext.getFormContext();
    applyCompetitorView(fc);
  }

  window.revops_comp_filter_onload         = onLoad;
  window.revops_comp_filter_onRegionChange = onRegionChange;
})();
