{% fetchxml account_tier %}
<fetch top="1">
  <entity name="account">
    <attribute name="revops_tier" />
    <link-entity name="contact" from="parentcustomerid" to="accountid" alias="c">
      <filter>
        <condition attribute="contactid" operator="eq" value="{{ user.id }}" />
      </filter>
    </link-entity>
  </entity>
</fetch>
{% endfetchxml %}

{% fetchxml current_case %}
<fetch top="1">
  <entity name="incident">
    <attribute name="incidentid" />
    <attribute name="revops_customerescalationreason" />
    <filter>
      <condition attribute="incidentid" operator="eq" value="{{ params.id }}" />
    </filter>
  </entity>
</fetch>
{% endfetchxml %}

{% fetchxml case_with_escalation %}
<fetch top="1">
  <entity name="incident">
    <attribute name="incidentid" />
    <filter type="and">
      <condition attribute="incidentid" operator="eq" value="{{ params.id }}" />
      <condition attribute="revops_customerescalationreason" operator="not-null" />
    </filter>
  </entity>
</fetch>
{% endfetchxml %}

{% assign has_escalation_value = false %}
{% if case_with_escalation.results.entities.size > 0 %}
  {% assign has_escalation_value = true %}
{% endif %}

(function() {
  'use strict';

  $(function() {
    // Get tier from account
    var tier = '{{ account_tier.results.entities[0].revops_tier | default: "" | downcase | strip | replace: " ", "" }}';
    
    // Check if escalation reason field has a value
    var hasEscalationValue = {{ has_escalation_value }};
    
    // Check if tier is 1 or 2 AND escalation reason is empty
    var isTier1or2 = ["tier1", "tier2", "1", "2"].includes(tier);
    var hasNoEscalation = !hasEscalationValue;
    var shouldShowButton = isTier1or2 && hasNoEscalation;