using System;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace RevOps.Plugins.CaseCustomerRespondedSetter
{
    /// <summary>
    /// Sets Case Status Reason to "Customer Responded" (234570003) when a customer responds via:
    /// - Portal Comment (adx_portalcomment)
    /// - Inbound Email (email, directioncode=false)
    ///
    /// Guards:
    /// 1) If activity is within 2 minutes of case creation → DO NOTHING (treat as case creation)
    /// 2) If case.statuscode = NEW (1) → DO NOTHING
    ///
    /// Resolved-case rule:
    /// - If case.statecode=1 (Resolved), only act when adx_resolutiondate exists AND
    ///   the customer response occurs within 72 hours of resolution.
    ///   In that window, reopen + set Customer Responded + clear adx_resolutiondate.
    /// - After 72 hours, DO NOTHING.
    /// </summary>
    public class CaseCustomerRespondedSetter : IPlugin
    {
        // === Entities ===
        private const string EntityIncident = "incident";
        private const string EntityEmail = "email";
        private const string EntityPortalComment = "adx_portalcomment";

        // === Case status reasons ===
        private const int CaseStatusReason_New = 1;
        private const int CaseStatusReason_CustomerResponded = 234570003;

        // === Email status reasons ===
        // Based on your org screenshots/observations
        private const int EmailStatusReason_Completed = 2;
        private const int EmailStatusReason_Received = 4;

        // === Fields ===
        private const string Field_Regarding = "regardingobjectid";
        private const string Field_StatusCode = "statuscode";
        private const string Field_StateCode = "statecode";
        private const string Field_CreatedOn = "createdon";
        private const string Field_EmailDirection = "directioncode";
        private const string Field_ResolutionDate = "adx_resolutiondate";

        private static readonly TimeSpan CaseCreationWindow = TimeSpan.FromMinutes(2);
        private static readonly TimeSpan ResolvedReopenWindow = TimeSpan.FromHours(72);

        public void Execute(IServiceProvider serviceProvider)
        {
            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            var tracing = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
            var factory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
            var service = factory.CreateOrganizationService(context.UserId);

            try
            {
                if (context.Depth > 2)
                {
                    tracing.Trace("Depth > 2; exiting.");
                    return;
                }

                if (!context.InputParameters.Contains("Target") || !(context.InputParameters["Target"] is Entity))
                {
                    tracing.Trace("No Target entity; exiting.");
                    return;
                }

                var target = (Entity)context.InputParameters["Target"];
                Entity post = (context.PostEntityImages != null && context.PostEntityImages.Contains("PostImage"))
                    ? context.PostEntityImages["PostImage"]
                    : null;

                // === Resolve Case ===
                var caseId = TryGetCaseIdFromRegarding(target, post);
                if (caseId == Guid.Empty)
                {
                    tracing.Trace("Not regarding a Case; exiting.");
                    return;
                }

                // === Determine activity timestamp and validate interaction ===
                DateTime? activityTimestamp = null;

                if (string.Equals(target.LogicalName, EntityPortalComment, StringComparison.OrdinalIgnoreCase))
                {
                    // Portal comment is always customer interaction
                    activityTimestamp = GetDateTime(target, post, Field_CreatedOn);
                    if (!activityTimestamp.HasValue)
                    {
                        tracing.Trace("Portal comment createdon missing; exiting.");
                        return;
                    }
                }
                else if (string.Equals(target.LogicalName, EntityEmail, StringComparison.OrdinalIgnoreCase))
                {
                    // directioncode: false=incoming, true=outgoing
                    var direction = GetBool(target, post, Field_EmailDirection);
                    if (!direction.HasValue)
                    {
                        tracing.Trace("Email directioncode missing; exiting.");
                        return;
                    }

                    if (direction.Value)
                    {
                        tracing.Trace("Email is outgoing; not a customer response; exiting.");
                        return;
                    }

                    // Only when email is Received/Completed
                    var emailStatus = GetOptionSetValue(target, post, Field_StatusCode);
                    if (!emailStatus.HasValue ||
                        (emailStatus.Value != EmailStatusReason_Received && emailStatus.Value != EmailStatusReason_Completed))
                    {
                        tracing.Trace("Email status not Received/Completed; exiting. statuscode={0}", emailStatus.HasValue ? emailStatus.Value.ToString() : "null");
                        return;
                    }

                    activityTimestamp = GetDateTime(target, post, Field_CreatedOn);
                    if (!activityTimestamp.HasValue)
                    {
                        tracing.Trace("Email createdon missing; exiting.");
                        return;
                    }
                }
                else
                {
                    tracing.Trace("Entity not in scope; exiting. entity={0}", target.LogicalName);
                    return;
                }

                // === Retrieve Case ===
                var incident = service.Retrieve(
                    EntityIncident,
                    caseId,
                    new ColumnSet(Field_CreatedOn, Field_StatusCode, Field_StateCode, Field_ResolutionDate)
                );

                var caseCreatedOn = incident.GetAttributeValue<DateTime>(Field_CreatedOn);
                var caseStatus = incident.GetAttributeValue<OptionSetValue>(Field_StatusCode);
                var caseState = incident.GetAttributeValue<OptionSetValue>(Field_StateCode);
                var resolutionDate = incident.GetAttributeValue<DateTime?>(Field_ResolutionDate);

                // === Guard 2: Case is NEW ===
                if (caseStatus != null && caseStatus.Value == CaseStatusReason_New)
                {
                    tracing.Trace("Case status is NEW; exiting.");
                    return;
                }

                // === Guard 1: Case creation window ===
                var activityTs = activityTimestamp.Value;
                if (Math.Abs((activityTs - caseCreatedOn).TotalMinutes) <= CaseCreationWindow.TotalMinutes)
                {
                    tracing.Trace("Activity within case creation window; treating as case creation; exiting.");
                    return;
                }

                // === Handle case by state ===
                int stateValue = caseState != null ? caseState.Value : 0;

                // Resolved (statecode=1): only within 72 hours of resolution date
                if (stateValue == 1)
                {
                    if (!resolutionDate.HasValue)
                    {
                        tracing.Trace("Case is resolved but adx_resolutiondate is null; exiting.");
                        return;
                    }

                    var deadline = resolutionDate.Value.ToUniversalTime().Add(ResolvedReopenWindow);
                    var nowUtc = DateTime.UtcNow;

                    if (nowUtc > deadline)
                    {
                        tracing.Trace("Resolved case response is after 72h window. now={0} deadline={1}; exiting.", nowUtc, deadline);
                        return;
                    }

                    // Within 72 hours: reopen + set customer responded + clear resolution date
                    var reopen = new Entity(EntityIncident, caseId);
                    reopen[Field_StateCode] = new OptionSetValue(0); // Active
                    reopen[Field_StatusCode] = new OptionSetValue(CaseStatusReason_CustomerResponded);
                    reopen[Field_ResolutionDate] = null;

                    tracing.Trace("Reopening case (within 72h) and setting status reason to Customer Responded; clearing adx_resolutiondate.");
                    service.Update(reopen);
                    return;
                }

                // Active (statecode=0): set status reason if not already
                if (stateValue == 0)
                {
                    if (caseStatus != null && caseStatus.Value == CaseStatusReason_CustomerResponded)
                    {
                        tracing.Trace("Case already Customer Responded; exiting.");
                        return;
                    }

                    var update = new Entity(EntityIncident, caseId);
                    update[Field_StatusCode] = new OptionSetValue(CaseStatusReason_CustomerResponded);

                    tracing.Trace("Setting active case status reason to Customer Responded.");
                    service.Update(update);
                    return;
                }

                // Any other state: do nothing
                tracing.Trace("Case statecode not supported for update (statecode={0}); exiting.", stateValue);
            }
            catch (Exception ex)
            {
                tracing.Trace("CaseCustomerRespondedSetter exception: {0}", ex);
                throw;
            }
        }

        // === Helpers ===

        private Guid TryGetCaseIdFromRegarding(Entity target, Entity post)
        {
            EntityReference regarding = null;

            if (target != null && target.Contains(Field_Regarding))
                regarding = target.GetAttributeValue<EntityReference>(Field_Regarding);

            if (regarding == null && post != null && post.Contains(Field_Regarding))
                regarding = post.GetAttributeValue<EntityReference>(Field_Regarding);

            if (regarding == null) return Guid.Empty;
            if (!string.Equals(regarding.LogicalName, EntityIncident, StringComparison.OrdinalIgnoreCase)) return Guid.Empty;

            return regarding.Id;
        }

        private DateTime? GetDateTime(Entity target, Entity post, string field)
        {
            if (target != null && target.Contains(field))
                return target.GetAttributeValue<DateTime?>(field);

            if (post != null && post.Contains(field))
                return post.GetAttributeValue<DateTime?>(field);

            return null;
        }

        private bool? GetBool(Entity target, Entity post, string field)
        {
            if (target != null && target.Contains(field))
                return target.GetAttributeValue<bool?>(field);

            if (post != null && post.Contains(field))
                return post.GetAttributeValue<bool?>(field);

            return null;
        }

        private int? GetOptionSetValue(Entity target, Entity post, string field)
        {
            if (target != null && target.Contains(field))
                return target.GetAttributeValue<OptionSetValue>(field)?.Value;

            if (post != null && post.Contains(field))
                return post.GetAttributeValue<OptionSetValue>(field)?.Value;

            return null;
        }
    }
}
