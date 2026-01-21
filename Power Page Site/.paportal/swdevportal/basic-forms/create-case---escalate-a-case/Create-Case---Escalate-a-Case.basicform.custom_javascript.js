{% fetchxml escalate_queue_lookup %}
<fetch top="1">
  <entity name="queue">
    <attribute name="queueid" />
    <attribute name="name" />
    <filter>
      <condition attribute="name" operator="eq" value="TSS Management" />
    </filter>
  </entity>
</fetch>
{% endfetchxml %}

{% if request.params.refid %}
{% fetchxml parent_case_lookup %}
<fetch top="1">
  <entity name="incident">
    <attribute name="incidentid" />
    <attribute name="title" />
    <attribute name="ticketnumber" />
    <attribute name="revops_cumulusaccountId" />
    <filter>
      <condition attribute="incidentid" operator="eq" value="{{ request.params.refid }}" />
    </filter>
  </entity>
</fetch>
{% endfetchxml %}
{% endif %}

(function() {
  'use strict';

  $(function() {
    // ...existing code...
    // Queue data from Liquid FetchXML
    var queueId = '{{ escalate_queue_lookup.results.entities[0].queueid }}';
    var queueName = '{{ escalate_queue_lookup.results.entities[0].name | escape }}';

    if (!queueId) {
      return;
    }

    var urlParams = new URLSearchParams(window.location.search);
    var parentCaseId = urlParams.get('refid') || '';
    var parentCaseName = '{% if parent_case_lookup.results.entities[0] %}{{ parent_case_lookup.results.entities[0].ticketnumber | escape }}{% endif %}';
    // ...existing code...
    // ...existing code...

    // ...existing code...
    // Queue prepopulation and hiding
    function fillAndHideQueue() {
      var $lookup = $("#revops_queue");
      if (!$lookup.length) {
        return setTimeout(fillAndHideQueue, 200);
      }

      $lookup.val(queueId).trigger("change");
      $("#revops_queue_name").val(queueName);
      $("#revops_queue_entityname").val("queue");

      var $row = $lookup.closest("tr");
      if ($row.length) {
        $row.css('display', 'none');
      } else {
        $lookup.closest("td, div.form-group, div.control").css('display', 'none');
      }
    }

    // Prepopulate Parent Case and Cumulus Account fields
    function fillParentCase() {
      if (!parentCaseId) {
        return;
      }

      var $parentCaseId = $("#parentcaseid, #ParentCaseId, input[name='parentcaseid']");
      var $parentCaseNameField = $("#parentcaseid_name, #ParentCaseId_name, input[name='parentcaseid_name']");
      var $parentCaseEntityName = $("#parentcaseid_entityname, #ParentCaseId_entityname, input[name='parentcaseid_entityname']");
      if (!$parentCaseId.length) {
        return setTimeout(fillParentCase, 200);
      }

      $parentCaseId.val(parentCaseId).trigger("change");
      if ($parentCaseNameField.length && parentCaseName) {
        $parentCaseNameField.val(parentCaseName);
      }
      if ($parentCaseEntityName.length) {
        $parentCaseEntityName.val("incident");
      }

      var $row = $parentCaseId.closest("tr");
      if ($row.length) {
        $row.css('display', 'none');
      } else {
        $parentCaseId.closest("td, div.form-group, div.control").css('display', 'none');
      }
    }

    setTimeout(function() {
      fillAndHideQueue();
      fillParentCase();
    }, 400);
  });

})();
