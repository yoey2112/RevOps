using System;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace RevOps.Plugins.CaseInteractionStamper
{
    public class CaseInteractionStamper : IPlugin
    {
        // === Entity logical names ===
        private const string EntityEmail = "email";
        private const string EntityPortalComment = "adx_portalcomment";
        private const string EntityLiveWorkItem = "msdyn_ocliveworkitem";
        private const string EntityIncident = "incident";

        // === Case field logical names ===
        private const string Case_LastAgentInteractionDate = "revops_lastagentinteractiondate";
        private const string Case_LastAutomatedInteractionDate = "revops_lastautomatedinteractiondate";
        private const string Case_LastCustomerInteractionDate = "revops_lastcustomerinteractiondate";
        private const string Case_LastInteractionDate = "revops_lastinteractiondate";
        private const string Case_LastInteraction = "revops_lastinteraction";
        private const string Case_LastEmailDirection = "revops_lastemaildirection";
        private const string Case_UnresponsiveCounter = "revops_unresponsivecounter";

        // === Email Status Reason values (email.statuscode) ===
        private const int EmailStatusReason_Sent = 3;
        private const int EmailStatusReason_Received = 4;

        // === LiveWorkItem Status Reason (msdyn_ocliveworkitem.statuscode) ===
        private const int LiveWorkItemStatusReason_Closed = 4;

        // === msdyn_channel values (global choice) ===
        private const int LiveWorkItemChannel_LiveChat = 192360000;
        private const int LiveWorkItemChannel_Voice = 192370000;
        private const int LiveWorkItemChannel_VoiceCall = 192440000;

        // === revops_lastinteraction (Choice) values ===
        // NOTE: Your error shows your Case field revops_lastinteraction currently only accepts:
        // 234570000, 234570001, 234570002
        // If you want Phone/Chat to be stored, you must add those options to the Case field.
        private const int LastInteraction_Email = 234570000;
        private const int LastInteraction_Note = 234570001;
        private const int LastInteraction_PortalComment = 234570002;
        private const int LastInteraction_Phone = 234570003;
        private const int LastInteraction_Chat = 234570004;

        // === Case.revops_lastemaildirection (Choice) values ===
        private const int EmailDirection_Incoming = 234570000;
        private const int EmailDirection_Outgoing = 234570001;

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

                if (!context.InputParameters.Contains("Target"))
                {
                    tracing.Trace("No Target in InputParameters; exiting.");
                    return;
                }

                var target = context.InputParameters["Target"] as Entity;
                if (target == null)
                {
                    tracing.Trace("Target is not an Entity; exiting.");
                    return;
                }

                var caseId = TryGetCaseIdFromRegarding(target, context, tracing);
                if (caseId == Guid.Empty)
                {
                    tracing.Trace("No related case found; exiting.");
                    return;
                }

                InteractionData interaction;
                if (!TryClassifyInteraction(target, context, tracing, out interaction))
                {
                    tracing.Trace("Interaction does not meet criteria; exiting.");
                    return;
                }

                var incident = service.Retrieve(
                    EntityIncident,
                    caseId,
                    new ColumnSet(
                        "statecode",
                        Case_LastAgentInteractionDate,
                        Case_LastAutomatedInteractionDate,
                        Case_LastCustomerInteractionDate,
                        Case_LastInteractionDate,
                        Case_LastInteraction,
                        Case_LastEmailDirection,
                        Case_UnresponsiveCounter
                    )
                );

                var stateCode = incident.GetAttributeValue<OptionSetValue>("statecode");
                if (stateCode != null && stateCode.Value != 0)
                {
                    tracing.Trace("Case not active (statecode={0}); exiting.", stateCode.Value);
                    return;
                }

                var curAgent = incident.GetAttributeValue<DateTime?>(Case_LastAgentInteractionDate);
                var curAuto = incident.GetAttributeValue<DateTime?>(Case_LastAutomatedInteractionDate);
                var curCust = incident.GetAttributeValue<DateTime?>(Case_LastCustomerInteractionDate);
                var curLast = incident.GetAttributeValue<DateTime?>(Case_LastInteractionDate);
                var curCounter = incident.GetAttributeValue<int?>(Case_UnresponsiveCounter);

                DateTime ts = interaction.TimestampUtc;

                DateTime? newAgent = curAgent;
                DateTime? newAuto = curAuto;
                DateTime? newCust = curCust;

                var update = new Entity(EntityIncident, caseId);
                bool anyChanges = false;

                // Stamp actor-specific fields (only if newer)
                if (interaction.Actor == InteractionActor.Customer)
                {
                    if (!curCust.HasValue || ts > ToUtc(curCust.Value))
                    {
                        update[Case_LastCustomerInteractionDate] = ts;
                        newCust = ts;
                        anyChanges = true;
                    }
                }
                else if (interaction.Actor == InteractionActor.Agent)
                {
                    if (!curAgent.HasValue || ts > ToUtc(curAgent.Value))
                    {
                        update[Case_LastAgentInteractionDate] = ts;
                        newAgent = ts;
                        anyChanges = true;
                    }
                }
                else if (interaction.Actor == InteractionActor.Automated)
                {
                    if (!curAuto.HasValue || ts > ToUtc(curAuto.Value))
                    {
                        update[Case_LastAutomatedInteractionDate] = ts;
                        newAuto = ts;
                        anyChanges = true;
                    }
                }
                else if (interaction.Actor == InteractionActor.Both)
                {
                    if (!curAgent.HasValue || ts > ToUtc(curAgent.Value))
                    {
                        update[Case_LastAgentInteractionDate] = ts;
                        newAgent = ts;
                        anyChanges = true;
                    }

                    if (!curCust.HasValue || ts > ToUtc(curCust.Value))
                    {
                        update[Case_LastCustomerInteractionDate] = ts;
                        newCust = ts;
                        anyChanges = true;
                    }
                }

                // Reset unresponsive counter to 0 when customer responds (Customer or Both)
                if (interaction.Actor == InteractionActor.Customer || interaction.Actor == InteractionActor.Both)
                {
                    if (!curCounter.HasValue || curCounter.Value != 0)
                    {
                        update[Case_UnresponsiveCounter] = 0;
                        anyChanges = true;
                        tracing.Trace("Customer response detected; set revops_unresponsivecounter = 0.");
                    }
                }

                DateTime? newMax = MaxNullableUtc(newAgent, newCust, newAuto);

                bool lastInteractionAdvanced = false;
                if (newMax.HasValue)
                {
                    if (!curLast.HasValue || newMax.Value > ToUtc(curLast.Value))
                    {
                        update[Case_LastInteractionDate] = newMax.Value;
                        anyChanges = true;
                        lastInteractionAdvanced = true;
                    }
                }

                // Only update channel + email direction when THIS event becomes the latest interaction
                if (lastInteractionAdvanced && newMax.HasValue && ts == newMax.Value)
                {
                    update[Case_LastInteraction] = new OptionSetValue(MapChannelToLastInteractionChoice(interaction.Channel));
                    anyChanges = true;

                    // NEW RULE:
                    // Customer => Incoming
                    // Agent/Automated => Outgoing
                    // Both => do not touch email direction
                    int? impliedEmailDirection = MapActorToEmailDirection(interaction.Actor);
                    if (impliedEmailDirection.HasValue)
                    {
                        update[Case_LastEmailDirection] = new OptionSetValue(impliedEmailDirection.Value);
                        anyChanges = true;
                        tracing.Trace("Set revops_lastemaildirection based on actor: {0}", impliedEmailDirection.Value);
                    }
                }

                if (!anyChanges)
                {
                    tracing.Trace("No case updates required; exiting.");
                    return;
                }

                tracing.Trace("Updating incident with stamped interaction fields.");
                service.Update(update);
            }
            catch (Exception ex)
            {
                var contextInfo = $"Message={context.MessageName}, Entity={context.PrimaryEntityName}, Stage={context.Stage}, Mode={context.Mode}, Depth={context.Depth}";
                var targetInfo = (context.InputParameters.Contains("Target") && context.InputParameters["Target"] is Entity e)
                    ? $"TargetLogical={e.LogicalName}, Id={(e.Id == Guid.Empty ? "EMPTY" : e.Id.ToString())}"
                    : "Target=NONE";

                tracing.Trace("CaseInteractionStamper exception. {0} | {1} | {2} | EX={3}", contextInfo, targetInfo, $"CorrelationId={context.CorrelationId}", ex);
                throw;
            }
        }

        private static DateTime ToUtc(DateTime dt)
        {
            return dt.Kind == DateTimeKind.Utc ? dt : dt.ToUniversalTime();
        }

        private static DateTime? MaxNullableUtc(DateTime? a, DateTime? b, DateTime? c)
        {
            DateTime? max = null;

            if (a.HasValue) max = a.Value;
            if (b.HasValue) max = !max.HasValue ? b.Value : (b.Value > max.Value ? b.Value : max.Value);
            if (c.HasValue) max = !max.HasValue ? c.Value : (c.Value > max.Value ? c.Value : max.Value);

            return max;
        }

        private int MapChannelToLastInteractionChoice(InteractionChannel channel)
        {
            if (channel == InteractionChannel.Email) return LastInteraction_Email;
            if (channel == InteractionChannel.PortalComment) return LastInteraction_PortalComment;
            if (channel == InteractionChannel.Chat) return LastInteraction_Chat;
            if (channel == InteractionChannel.Phone) return LastInteraction_Phone;

            return LastInteraction_Email;
        }

        // NEW: Email direction implied by actor
        private int? MapActorToEmailDirection(InteractionActor actor)
        {
            if (actor == InteractionActor.Customer) return EmailDirection_Incoming;
            if (actor == InteractionActor.Agent) return EmailDirection_Outgoing;
            if (actor == InteractionActor.Automated) return EmailDirection_Outgoing;

            // Both (phone/chat) => do not change email direction
            return null;
        }

        private Guid TryGetCaseIdFromRegarding(Entity target, IPluginExecutionContext context, ITracingService tracing)
        {
            EntityReference regarding = null;

            if (target.Contains("regardingobjectid"))
                regarding = target.GetAttributeValue<EntityReference>("regardingobjectid");

            if (regarding == null && context.PostEntityImages != null && context.PostEntityImages.Contains("PostImage"))
            {
                var post = context.PostEntityImages["PostImage"];
                if (post != null && post.Contains("regardingobjectid"))
                    regarding = post.GetAttributeValue<EntityReference>("regardingobjectid");
            }

            if (regarding == null) return Guid.Empty;
            if (!string.Equals(regarding.LogicalName, EntityIncident, StringComparison.OrdinalIgnoreCase)) return Guid.Empty;

            return regarding.Id;
        }

        private bool TryClassifyInteraction(Entity target, IPluginExecutionContext context, ITracingService tracing, out InteractionData interaction)
        {
            interaction = new InteractionData();

            var post = (context.PostEntityImages != null && context.PostEntityImages.Contains("PostImage"))
                ? context.PostEntityImages["PostImage"]
                : null;

            if (string.Equals(target.LogicalName, EntityPortalComment, StringComparison.OrdinalIgnoreCase))
            {
                var createdOn = GetDateTime(post, target, "createdon");
                if (!createdOn.HasValue) return false;

                interaction.Channel = InteractionChannel.PortalComment;
                interaction.Actor = InteractionActor.Customer;
                interaction.TimestampUtc = ToUtc(createdOn.Value);
                return true;
            }

            if (string.Equals(target.LogicalName, EntityEmail, StringComparison.OrdinalIgnoreCase))
            {
                var statusReason = GetOptionSetValue(post, target, "statuscode");
                var direction = GetBool(post, target, "directioncode"); // false=incoming, true=outgoing

                if (!statusReason.HasValue || !direction.HasValue) return false;

                if (!direction.Value && statusReason.Value == EmailStatusReason_Received)
                {
                    var createdOn = GetDateTime(post, target, "createdon");
                    if (!createdOn.HasValue) return false;

                    interaction.Channel = InteractionChannel.Email;
                    interaction.Actor = InteractionActor.Customer;
                    interaction.TimestampUtc = ToUtc(createdOn.Value);
                    return true;
                }

                if (direction.Value && statusReason.Value == EmailStatusReason_Sent)
                {
                    var isWorkflow = GetBool(post, target, "isworkflowcreated") ?? false;

                    var sentOn = GetDateTime(post, target, "senton");
                    var createdOn = GetDateTime(post, target, "createdon");
                    var ts = sentOn.HasValue ? sentOn : createdOn;

                    if (!ts.HasValue) return false;

                    interaction.Channel = InteractionChannel.Email;
                    interaction.Actor = isWorkflow ? InteractionActor.Automated : InteractionActor.Agent;
                    interaction.TimestampUtc = ToUtc(ts.Value);
                    return true;
                }

                return false;
            }

            if (string.Equals(target.LogicalName, EntityLiveWorkItem, StringComparison.OrdinalIgnoreCase))
            {
                var statusReason = GetOptionSetValue(post, target, "statuscode");
                if (!statusReason.HasValue || statusReason.Value != LiveWorkItemStatusReason_Closed) return false;

                var channel = GetOptionSetValue(post, target, "msdyn_channel");
                if (!channel.HasValue) return false;

                var actualEnd = GetDateTime(post, target, "actualend");
                var msdynCreatedOn = GetDateTime(post, target, "msdyn_createdon");

                var ts = actualEnd.HasValue ? actualEnd : msdynCreatedOn;
                if (!ts.HasValue) return false;

                if (channel.Value == LiveWorkItemChannel_LiveChat)
                {
                    interaction.Channel = InteractionChannel.Chat;
                }
                else if (channel.Value == LiveWorkItemChannel_Voice || channel.Value == LiveWorkItemChannel_VoiceCall)
                {
                    interaction.Channel = InteractionChannel.Phone;
                }
                else
                {
                    return false;
                }

                interaction.Actor = InteractionActor.Both;
                interaction.TimestampUtc = ToUtc(ts.Value);
                return true;
            }

            return false;
        }

        private DateTime? GetDateTime(Entity post, Entity target, string field)
        {
            if (target != null && target.Contains(field))
                return target.GetAttributeValue<DateTime?>(field);

            if (post != null && post.Contains(field))
                return post.GetAttributeValue<DateTime?>(field);

            return null;
        }

        private bool? GetBool(Entity post, Entity target, string field)
        {
            if (target != null && target.Contains(field))
                return target.GetAttributeValue<bool?>(field);

            if (post != null && post.Contains(field))
                return post.GetAttributeValue<bool?>(field);

            return null;
        }

        private int? GetOptionSetValue(Entity post, Entity target, string field)
        {
            if (TryGetOptionSetValueFromEntity(target, field, out int? v1)) return v1;
            if (TryGetOptionSetValueFromEntity(post, field, out int? v2)) return v2;
            return null;
        }

        private bool TryGetOptionSetValueFromEntity(Entity entity, string field, out int? value)
        {
            value = null;
            if (entity == null || !entity.Contains(field)) return false;

            object raw = entity[field];
            if (raw == null) return false;

            var osv = raw as OptionSetValue;
            if (osv != null)
            {
                value = osv.Value;
                return true;
            }

            var col = raw as OptionSetValueCollection;
            if (col != null)
            {
                if (col.Count > 0 && col[0] != null)
                {
                    value = col[0].Value;
                    return true;
                }
                return true;
            }

            return false;
        }

        private struct InteractionData
        {
            public InteractionChannel Channel;
            public InteractionActor Actor;
            public DateTime TimestampUtc;
        }

        private enum InteractionChannel
        {
            Email = 1,
            PortalComment = 2,
            Chat = 3,
            Phone = 4
        }

        private enum InteractionActor
        {
            Customer = 1,
            Agent = 2,
            Automated = 3,
            Both = 4
        }
    }
}
