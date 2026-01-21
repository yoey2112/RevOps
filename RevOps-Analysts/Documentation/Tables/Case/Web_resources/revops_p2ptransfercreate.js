// revops_/js/p2p_core.js
(function () {
  // ===== CONFIG =====
  var CUMULUS_ENTITY_LOGICAL   = "revops_cumulusaccount";
  var CUMULUS_NAME_ATTR        = "revops_name";
  var CUMULUS_PARENT_ACCOUNT_ATTR = "revops_account";             // Cumulus -> Account (lookup)

  // NEW: ISO2 code on Cumulus Account (Single line of text, 2 chars)
  // >>> confirm this logical name in your environment <<<
  var CUMULUS_ISO2_ATTR        = "revops_iso3166alpha2countrycode";

  // Case fields
  var CASE_CUMULUS_LOOKUP      = "revops_cumulusaccount";         // Case -> Cumulus lookup
  var CASE_ACCOUNT_LOOKUP      = "revops_account";                 // Case -> Account (custom lookup on Case)
  var CASE_CUSTOMER_LOOKUP     = "customerid";                     // Case -> Account/Contact (polymorphic)
  var CASE_CONTACT_LOOKUP      = "primarycontactid";               // Case -> Contact
  var CASE_COMPETITOR_REGION   = "revops_competitorregion";        // Case -> Region (lookup)

  // Region table
  var REGION_ENTITY_LOGICAL    = "msdyn_region";

  // NEW: Region "code" column used to match ISO2 (text)
  // >>> set this to the Region table’s code logical name (e.g., "revops_regioncode" or "msdyn_code") <<<
  var REGION_CODE_ATTR         = "msdyn_regioncode";

  // Defaults / UX
  var MAIN_FORMID              = "bb897864-d393-f011-b4cc-6045bdfa0630";
  var CASETYPE_ATTRIBUTE       = "casetypecode";                    // Case Type (Choice)
  var CASETYPE_LABEL           = "Migration";

  var SUBJECT_ENVVAR_SCHEMA    = "revops_subjectcspp2p";            // env var stores Subject GUID
  var SUBJECT_NAME             = "CSP - P2P";

  var QUEUE_ATTRIBUTE          = "revops_queue";
  var QUEUE_NAME               = "Technical Onboarding";

  var SERVICE_ATTRIBUTE        = "revops_service";
  var SERVICE_ENTITY           = "revops_service";
  var SERVICE_NAME             = "Microsoft 365";

  // Required fields
  var TRANSFER_WORKLOAD_ATTR   = "revops_transferworkload";         // make business required
  // ==================

  // ---------- helpers ----------
  function esc(s){ return String(s).replace(/'/g,"''"); }
  function stripGuid(s){ return (s||"").replace(/[{}]/g,""); }

  function setLookup(fc, attr, id, name, entity){
    var a = fc.getAttribute(attr); if(!a) return;
    a.setValue(id ? [{ id: "{"+stripGuid(id)+"}", name: name||"", entityType: entity }] : null);
  }
  function getLookup(fc, attr){
    var a = fc.getAttribute(attr); if(!a) return null;
    var v = a.getValue();
    if(Array.isArray(v) && v.length){
      return { id: stripGuid(v[0].id), name: v[0].name||"", entityType: v[0].entityType||v[0].entity||"" };
    }
    return null;
  }

  function getChoiceValue(entity, attr, label){
    var url = Xrm.Utility.getGlobalContext().getClientUrl()
      + "/api/data/v9.2/EntityDefinitions(LogicalName='" + entity + "')"
      + "/Attributes(LogicalName='" + attr + "')"
      + "/Microsoft.Dynamics.CRM.PicklistAttributeMetadata?$select=LogicalName&$expand=OptionSet($select=Options)";
    return fetch(url,{headers:{"OData-MaxVersion":"4.0","OData-Version":"4.0","Accept":"application/json"}})
      .then(r=>{ if(!r.ok) throw new Error(r.status); return r.json(); })
      .then(meta=>{
        var opts=(meta&&meta.OptionSet&&meta.OptionSet.Options)||[];
        for(var i=0;i<opts.length;i++){
          var lab=opts[i].Label && opts[i].Label.UserLocalizedLabel && opts[i].Label.UserLocalizedLabel.Label;
          if(lab && lab.toLowerCase()===String(CASETYPE_LABEL).toLowerCase()) return opts[i].Value;
        }
        return null;
      }).catch(()=>null);
  }

  function getEntityKeys(entity){
    var url = Xrm.Utility.getGlobalContext().getClientUrl()
      + "/api/data/v9.2/EntityDefinitions(LogicalName='" + entity + "')?$select=PrimaryIdAttribute,PrimaryNameAttribute";
    return fetch(url,{headers:{"OData-MaxVersion":"4.0","OData-Version":"4.0","Accept":"application/json"}})
      .then(r=>{ if(!r.ok) throw new Error(r.status); return r.json(); })
      .then(meta=>({ idAttr: meta.PrimaryIdAttribute, nameAttr: meta.PrimaryNameAttribute }));
  }

  function findByName(entity, name){
    return getEntityKeys(entity).then(keys=>{
      var sel = "$select="+keys.idAttr+","+keys.nameAttr+"&$top=1";
      var withState = sel + "&$filter=statecode eq 0 and " + keys.nameAttr + " eq '" + esc(name) + "'";
      var noState   = sel + "&$filter=" + keys.nameAttr + " eq '" + esc(name) + "'";
      return Xrm.WebApi.retrieveMultipleRecords(entity,"?"+withState).then(res=>{
        if(res.entities && res.entities.length){
          var e=res.entities[0]; return { id:e[keys.idAttr], name:e[keys.nameAttr], type:entity };
        }
        return Xrm.WebApi.retrieveMultipleRecords(entity,"?"+noState).then(res2=>{
          if(res2.entities && res2.entities.length){
            var e2=res2.entities[0]; return { id:e2[keys.idAttr], name:e2[keys.nameAttr], type:entity };
          }
          return null;
        });
      });
    });
  }

  function findQueueByName(name){
    var qs="$select=queueid,name&$top=1&$filter=statecode eq 0 and name eq '"+esc(name)+"'";
    return Xrm.WebApi.retrieveMultipleRecords("queue","?"+qs)
      .then(res=> res.entities && res.entities.length ? { id:res.entities[0].queueid, name:res.entities[0].name, type:"queue" } : null)
      .catch(()=>null);
  }

  function getEnvironmentVariable(schemaName){
    var base=Xrm.Utility.getGlobalContext().getClientUrl();
    var url=base+"/api/data/v9.2/environmentvariabledefinitions"
      +"?$select=schemaname,defaultvalue"
      +"&$filter=schemaname eq '"+esc(schemaName)+"'"
      +"&$expand=environmentvariabledefinition_environmentvariablevalue($select=value)";
    return fetch(url,{headers:{"OData-MaxVersion":"4.0","OData-Version":"4.0","Accept":"application/json"}})
      .then(r=>{ if(!r.ok) throw new Error(r.status); return r.json(); })
      .then(d=>{
        var def=d&&d.value&&d.value[0]; if(!def) return null;
        var exp=(def.environmentvariabledefinition_environmentvariablevalue||[])[0];
        return (exp && exp.value) || def.defaultvalue || null;
      })
      .catch(()=>null);
  }

  // ---------- data fetchers ----------
  // From Cumulus -> get parent Account (id + name)
  function fetchParentAccountFromCumulus(cumulusId){
    if(!cumulusId) return Promise.resolve(null);
    var qs="?$select=_"+CUMULUS_PARENT_ACCOUNT_ATTR+"_value"
          +"&$expand="+CUMULUS_PARENT_ACCOUNT_ATTR+"($select=accountid,name)";
    return Xrm.WebApi.retrieveRecord(CUMULUS_ENTITY_LOGICAL, cumulusId, qs)
      .then(r=>{
        var accId   = r["_"+CUMULUS_PARENT_ACCOUNT_ATTR+"_value"];
        var accName = r["_"+CUMULUS_PARENT_ACCOUNT_ATTR+"_value@OData.Community.Display.V1.FormattedValue"] || "";
        return accId ? { id: stripGuid(accId), name: accName } : null;
      });
  }

  // NEW: Prefill Region by matching Cumulus ISO2 -> Region.RegionCode
  function prefillRegionFromCumulusISO2(fc){
    var cum = getLookup(fc, CASE_CUMULUS_LOOKUP);
    if(!cum) return Promise.resolve();

    return Xrm.WebApi.retrieveRecord(
      CUMULUS_ENTITY_LOGICAL,
      cum.id,
      "?$select=" + CUMULUS_ISO2_ATTR
    )
    .then(function(c){
      var iso2 = (c[CUMULUS_ISO2_ATTR] || "").trim();
      if(!iso2){
        setLookup(fc, CASE_COMPETITOR_REGION, null, null, null);
        return;
      }
      var iso2U = iso2.toUpperCase();

      // build a filter using Region Code
      return getEntityKeys(REGION_ENTITY_LOGICAL).then(function(keys){
        var sel = "$select="+keys.idAttr+","+keys.nameAttr+"&$top=1";
        var filter = sel + "&$filter=statecode eq 0 and " + REGION_CODE_ATTR + " eq '" + esc(iso2U) + "'";
        return Xrm.WebApi
          .retrieveMultipleRecords(REGION_ENTITY_LOGICAL, "?" + filter)
          .then(function(res){
            if(res.entities && res.entities.length){
              var r = res.entities[0];
              setLookup(fc, CASE_COMPETITOR_REGION, r[keys.idAttr], r[keys.nameAttr], REGION_ENTITY_LOGICAL);
            }else{
              // not found -> clear
              setLookup(fc, CASE_COMPETITOR_REGION, null, null, null);
            }
          });
      });
    })
    .catch(function(){ /* swallow */ });
  }

  // Filter Contact lookup to Contacts under revops_account (Case)
  function addContactFilter(fc){
    var ctrl = fc.getControl(CASE_CONTACT_LOOKUP);
    if(!ctrl) return;

    function wire(){
      try{ ctrl.clearCustomFilter(); }catch(e){}
      var acc = getLookup(fc, CASE_ACCOUNT_LOOKUP);
      if(!acc) return;

      var fetch =
        "<filter type='and'>" +
          "<condition attribute='parentcustomerid' operator='eq' uitype='account' value='{"+acc.id+"}' />" +
        "</filter>";

      ctrl.addPreSearch(function(){
        ctrl.addCustomFilter(fetch, "contact");
      });
    }

    wire();
    var accAttr = fc.getAttribute(CASE_ACCOUNT_LOOKUP);
    if(accAttr){ accAttr.addOnChange(function(){ wire(); }); }
  }

  // When Contact changes, populate Customer (polymorphic) with that Contact
  function onContactChange(executionContext){
    var fc = executionContext.getFormContext();
    var contact = getLookup(fc, CASE_CONTACT_LOOKUP);
    if(contact){
      setLookup(fc, CASE_CUSTOMER_LOOKUP, contact.id, contact.name, "contact");
    }else{
      setLookup(fc, CASE_CUSTOMER_LOOKUP, null, null, null);
    }
  }

  // ---------- Case On Load ----------
  function onCaseLoad(executionContext){
    var fc = executionContext.getFormContext();

    // Make Transfer Workload business required
    var tw = fc.getAttribute(TRANSFER_WORKLOAD_ATTR);
    if (tw) { try { tw.setRequiredLevel("required"); } catch(e){} }

    // Ensure revops_account is set from Cumulus' parent Account
    var cum = getLookup(fc, CASE_CUMULUS_LOOKUP);
    if(cum){
      fetchParentAccountFromCumulus(cum.id).then(function(acc){
        if(acc){ setLookup(fc, CASE_ACCOUNT_LOOKUP, acc.id, acc.name, "account"); }
      });
    }

    // Filter Contact by the Case.revops_account
    addContactFilter(fc);

    // Prefill Region by ISO2 -> Region Code match
    prefillRegionFromCumulusISO2(fc);

    // Re-run logic if Cumulus changes
    var cumAttr = fc.getAttribute(CASE_CUMULUS_LOOKUP);
    if(cumAttr){
      cumAttr.addOnChange(function(){
        var c = getLookup(fc, CASE_CUMULUS_LOOKUP);
        if(c){
          fetchParentAccountFromCumulus(c.id).then(function(acc){
            setLookup(fc, CASE_ACCOUNT_LOOKUP, acc ? acc.id : null, acc ? acc.name : null, acc ? "account" : null);
            addContactFilter(fc);
          });
          prefillRegionFromCumulusISO2(fc);
        }else{
          setLookup(fc, CASE_ACCOUNT_LOOKUP, null, null, null);
          addContactFilter(fc);
          setLookup(fc, CASE_COMPETITOR_REGION, null, null, null);
        }
      });
    }

    // Wire Contact -> Customer sync
    var contactAttr = fc.getAttribute(CASE_CONTACT_LOOKUP);
    if(contactAttr){ contactAttr.addOnChange(onContactChange); }
  }

  // ---------- Ribbon command: open Case with defaults ----------
  function openp2pTransfer(primaryControl, selectedItemIds) {
    try {
      // Normalize selected org IDs
      var ids=[];
      if(Array.isArray(selectedItemIds)) ids = selectedItemIds.slice();
      else if(typeof selectedItemIds==="string") ids = selectedItemIds.split(",").map(s=>s.trim());
      else if(selectedItemIds && selectedItemIds.forEach) selectedItemIds.forEach(x=>ids.push(String(x)));
      ids = ids.filter(Boolean).map(stripGuid);

      if(!ids.length){
        Xrm.Navigation.openAlertDialog({ text:"Select at least one organization in the subgrid." });
        return;
      }

      var ctx = primaryControl;
      if(!ctx || !ctx.data || !ctx.data.entity){
        Xrm.Navigation.openAlertDialog({ text:"Primary form context not available." });
        return;
      }

      var cumulusId = stripGuid(ctx.data.entity.getId()||"");
      if(!cumulusId){
        Xrm.Navigation.openAlertDialog({ text:"Save the Cumulus Account before using this action." });
        return;
      }

      var cumulusName = (ctx.getAttribute && ctx.getAttribute(CUMULUS_NAME_ATTR)) ? ctx.getAttribute(CUMULUS_NAME_ATTR).getValue() : null;

      // Fetch parent Account from the current Cumulus form (if lookup present)
      var parentAccountRef = (ctx.getAttribute && ctx.getAttribute(CUMULUS_PARENT_ACCOUNT_ATTR)) ? ctx.getAttribute(CUMULUS_PARENT_ACCOUNT_ATTR).getValue() : null;

      var caseTitle = ids.length + " - P2P Transfer for " + (cumulusName || "Cumulus Account");

      var formParams = {
        revops_p2pautocreate: true,
        revops_transferorgs: JSON.stringify(ids),
        revops_oforganizations: ids.length,
        revops_selectedorgs: JSON.stringify(ids),
        title: caseTitle
      };

      // Case ↔ Cumulus
      formParams[CASE_CUMULUS_LOOKUP] = cumulusId;
      formParams[CASE_CUMULUS_LOOKUP + "name"] = cumulusName || "";
      formParams[CASE_CUMULUS_LOOKUP + "type"] = CUMULUS_ENTITY_LOGICAL;

      // Set Case.revops_account (parent Account) — do NOT set customerid here
      if(Array.isArray(parentAccountRef) && parentAccountRef.length > 0){
        var acc = parentAccountRef[0];
        formParams[CASE_ACCOUNT_LOOKUP]        = stripGuid(acc.id || "");
        formParams[CASE_ACCOUNT_LOOKUP+"name"] = acc.name || "";
        formParams[CASE_ACCOUNT_LOOKUP+"type"] = "account";
      }

      // Resolve Subject, CaseType, Queue, Service
      getEnvironmentVariable(SUBJECT_ENVVAR_SCHEMA)
        .then(function (subjectIdFromEnv) {
          var subjectIdClean = stripGuid(subjectIdFromEnv || "");
          if(subjectIdClean){
            formParams["subjectid"]     = subjectIdClean;
            formParams["subjectidname"] = SUBJECT_NAME;
            formParams["subjectidtype"] = "subject";
          }
          return Promise.all([
            getChoiceValue("incident", CASETYPE_ATTRIBUTE, CASETYPE_LABEL),
            findQueueByName(QUEUE_NAME),
            findByName(SERVICE_ENTITY, SERVICE_NAME)
          ]);
        })
        .then(function (r) {
          var caseTypeValue = r[0], queueRef = r[1], serviceRef = r[2];

          if(caseTypeValue !== null) formParams[CASETYPE_ATTRIBUTE] = caseTypeValue;

          if(queueRef){
            formParams[QUEUE_ATTRIBUTE] = queueRef.id;
            formParams[QUEUE_ATTRIBUTE+"name"] = queueRef.name;
            formParams[QUEUE_ATTRIBUTE+"type"] = queueRef.type;
          }
          if(serviceRef){
            formParams[SERVICE_ATTRIBUTE] = serviceRef.id;
            formParams[SERVICE_ATTRIBUTE+"name"] = serviceRef.name;
            formParams[SERVICE_ATTRIBUTE+"type"] = serviceRef.type;
          }

          var pageInput = {
            pageType:"entityrecord",
            entityName:"incident",
            formId: MAIN_FORMID,
            createFromEntity:{ entityType:CUMULUS_ENTITY_LOGICAL, id:cumulusId, name:cumulusName },
            data: formParams
          };

          if(Xrm.App && Xrm.App.sidePanes && Xrm.App.sidePanes.createPane){
            Xrm.App.sidePanes.createPane({ title:"P2P Transfer", paneId:"revops_quickp2p", width:600, canClose:true })
              .then(p=>p.navigate(pageInput))
              .catch(()=>Xrm.Navigation.openForm({ entityName:"incident", formId: MAIN_FORMID }, formParams));
          }else{
            Xrm.Navigation.openForm({ entityName:"incident", formId: MAIN_FORMID }, formParams);
          }
        })
        .catch(function(e){
          Xrm.Navigation.openAlertDialog({ text: "Could not open Case. " + (e && e.message ? e.message : e) });
        });

    } catch(e){
      Xrm.Navigation.openAlertDialog({ text: "Unexpected error: " + e.message });
    }
  }

  // ---------- expose ----------
  window.revops_case_onload       = onCaseLoad;        // Case form On Load
  window.revops_openp2pTransfer   = openp2pTransfer;   // Ribbon command
  window.revops_onContactChange   = onContactChange;   // Contact On Change
})();
