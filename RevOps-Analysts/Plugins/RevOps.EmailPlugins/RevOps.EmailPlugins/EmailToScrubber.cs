using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace RevOps.EmailPlugins
{
    public class EmailToScrubber : IPlugin
    {
        // Entities
        private const string ENTITY_EMAIL = "email";
        private const string ENTITY_INCIDENT = "incident";
        private const string ENTITY_QUEUE = "queue";

        // Email attributes
        private const string ATTR_EMAIL_TO = "to";
        private const string ATTR_EMAIL_FROM = "from";
        private const string ATTR_EMAIL_REGARDING = "regardingobjectid";
        private const string ATTR_EMAIL_DIRECTION = "directioncode"; // bool: true = outgoing

        // Case -> Queue lookup (from your working EmailFromSetter)
        private const string ATTR_INCIDENT_QUEUE = "revops_queue"; // Case -> Queue

        // Queue attributes
        private const string ATTR_QUEUE_DS = "revops_defaultsendingemail"; // Queue -> BASIC queue
        private const string ATTR_QUEUE_EMAIL = "emailaddress";               // Basic queue email
        private const string ATTR_QUEUE_NAME = "name";

        public void Execute(IServiceProvider serviceProvider)
        {
            var trace = (ITracingService)serviceProvider.GetService(typeof(ITracingService));
            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            var factory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
            var svc = factory.CreateOrganizationService(context.UserId);

            trace.Trace("EmailToScrubber START. Message={0}, Primary={1}, Stage={2}",
                context.MessageName, context.PrimaryEntityName, context.Stage);

            try
            {
                if (!string.Equals(context.PrimaryEntityName, ENTITY_EMAIL, StringComparison.OrdinalIgnoreCase))
                {
                    trace.Trace("Primary entity is not email. Exiting.");
                    return;
                }

                // CREATE (Pre) – replies are created server-side, so scrub TO before the form opens
                if (context.MessageName.Equals("Create", StringComparison.OrdinalIgnoreCase))
                {
                    HandleCreate(context, svc, trace);
                    return;
                }

                // UPDATE (Pre) – scrub TO only
                if (context.MessageName.Equals("Update", StringComparison.OrdinalIgnoreCase))
                {
                    HandleUpdate(context, svc, trace);
                    return;
                }

                // SEND (Pre) – set FROM (if needed) + scrub TO again as safety net
                if (context.MessageName.Equals("Send", StringComparison.OrdinalIgnoreCase))
                {
                    HandleSend(context, svc, trace);
                    return;
                }

                trace.Trace("Unsupported message. Exiting.");
            }
            catch (Exception ex)
            {
                trace.Trace("EmailToScrubber ERROR: {0}", ex.ToString());
                // Normally don't block sends:
                // throw;
            }
            finally
            {
                trace.Trace("EmailToScrubber END.");
            }
        }

        // ---------------- CREATE: scrub TO only (replies) ----------------

        private void HandleCreate(IPluginExecutionContext ctx, IOrganizationService svc, ITracingService trace)
        {
            if (!ctx.InputParameters.Contains("Target") || !(ctx.InputParameters["Target"] is Entity target))
            {
                trace.Trace("HandleCreate: No Target.");
                return;
            }

            if (!string.Equals(target.LogicalName, ENTITY_EMAIL, StringComparison.OrdinalIgnoreCase))
            {
                trace.Trace("HandleCreate: Target not email.");
                return;
            }

            // Only outgoing emails
            if (!IsOutgoing(target))
            {
                trace.Trace("HandleCreate: Not outgoing. Skipping.");
                return;
            }

            // No pre-image on Create, just use Target as snapshot
            var snapshot = target;
            var writeBack = target; // Pre-Op: modify Target directly

            ScrubTo(snapshot, writeBack, svc, trace, changeFrom: false);
        }

        // ---------------- UPDATE: scrub TO only ----------------

        private void HandleUpdate(IPluginExecutionContext ctx, IOrganizationService svc, ITracingService trace)
        {
            if (!ctx.InputParameters.Contains("Target") || !(ctx.InputParameters["Target"] is Entity target))
            {
                trace.Trace("HandleUpdate: No Target.");
                return;
            }

            if (!string.Equals(target.LogicalName, ENTITY_EMAIL, StringComparison.OrdinalIgnoreCase))
            {
                trace.Trace("HandleUpdate: Target not email.");
                return;
            }

            var pre = (ctx.PreEntityImages != null && ctx.PreEntityImages.Contains("PreImage"))
                ? ctx.PreEntityImages["PreImage"]
                : null;

            var snapshot = MergeWithPreImage(target, pre, new[]
            {
                ATTR_EMAIL_TO,
                ATTR_EMAIL_FROM,
                ATTR_EMAIL_REGARDING,
                ATTR_EMAIL_DIRECTION
            });

            var writeBack = target; // Pre-Op: modify Target directly

            // Only outgoing emails
            if (!IsOutgoing(snapshot))
            {
                trace.Trace("HandleUpdate: Not outgoing. Skipping.");
                return;
            }

            ScrubTo(snapshot, writeBack, svc, trace, changeFrom: false);
        }

        // ---------------- SEND: set FROM + scrub TO ----------------

        private void HandleSend(IPluginExecutionContext ctx, IOrganizationService svc, ITracingService trace)
        {
            if (!ctx.InputParameters.Contains("EmailId") ||
                !(ctx.InputParameters["EmailId"] is Guid emailId) ||
                emailId == Guid.Empty)
            {
                trace.Trace("HandleSend: No EmailId.");
                return;
            }

            trace.Trace("HandleSend: EmailId={0}", emailId);

            var cols = new ColumnSet(ATTR_EMAIL_TO, ATTR_EMAIL_FROM, ATTR_EMAIL_REGARDING, ATTR_EMAIL_DIRECTION);
            var snapshot = svc.Retrieve(ENTITY_EMAIL, emailId, cols);

            // Only outgoing emails
            if (!IsOutgoing(snapshot))
            {
                trace.Trace("HandleSend: Not outgoing. Skipping.");
                return;
            }

            var writeBack = new Entity(ENTITY_EMAIL) { Id = emailId };

            if (ScrubTo(snapshot, writeBack, svc, trace, changeFrom: true))
            {
                trace.Trace("HandleSend: Changes detected. Updating email.");
                svc.Update(writeBack);
            }
            else
            {
                trace.Trace("HandleSend: No changes required.");
            }
        }

        // ---------------- Core logic ----------------

        /// <summary>
        /// Scrubs the TO field and (optionally) sets FROM to the Case's basic queue
        /// (DefaultSendingEmail or CaseQueue). Returns true if writeBack was changed.
        /// </summary>
        private bool ScrubTo(
            Entity emailSnapshot,
            Entity writeBack,
            IOrganizationService svc,
            ITracingService trace,
            bool changeFrom)
        {
            bool changed = false;

            // Must be regarding a Case
            var regarding = emailSnapshot.GetAttributeValue<EntityReference>(ATTR_EMAIL_REGARDING);
            if (regarding == null || !string.Equals(regarding.LogicalName, ENTITY_INCIDENT, StringComparison.OrdinalIgnoreCase))
            {
                trace.Trace("ScrubTo: Not regarding a Case. Skipping.");
                return false;
            }

            trace.Trace("ScrubTo: Regarding Case {0}", regarding.Id);

            // Case -> Queue / Default Sending Email
            var (caseQueueRef, basicQueueRef, basicQueueEmail) = ResolveQueues(svc, regarding.Id, trace);
            if (caseQueueRef == null && basicQueueRef == null)
            {
                trace.Trace("ScrubTo: Case has no queue or DS queue. Skipping.");
                return false;
            }

            // Basic queue = DS queue if set, else case queue
            var finalQueueRef = basicQueueRef ?? caseQueueRef;
            var finalQueueEmail = basicQueueEmail;

            trace.Trace("ScrubTo: finalQueueRef={0}, finalQueueEmail={1}",
                finalQueueRef != null ? finalQueueRef.Id.ToString() : "null",
                finalQueueEmail ?? "(null)");

            // Current FROM
            var fromList = emailSnapshot.GetAttributeValue<EntityCollection>(ATTR_EMAIL_FROM);
            var existingFromQueue = GetFromQueueRef(fromList);

            // Decide whether we change FROM (only on Send)
            EntityReference effectiveFromQueue = existingFromQueue;

            if (changeFrom)
            {
                if (existingFromQueue == null && finalQueueRef != null)
                {
                    // FROM is not a queue → set to basic queue
                    var ap = new Entity("activityparty");
                    ap["partyid"] = finalQueueRef;
                    if (!string.IsNullOrWhiteSpace(finalQueueEmail))
                        ap["addressused"] = finalQueueEmail;

                    writeBack[ATTR_EMAIL_FROM] = new EntityCollection(new List<Entity> { ap });
                    effectiveFromQueue = finalQueueRef;
                    changed = true;

                    trace.Trace("ScrubTo: FROM set to queue {0} ({1})",
                        finalQueueRef.Id, string.IsNullOrWhiteSpace(finalQueueEmail) ? "(no email)" : finalQueueEmail);
                }
                else
                {
                    // User already picked a queue; do not override
                    effectiveFromQueue = existingFromQueue ?? finalQueueRef;
                    if (existingFromQueue != null)
                        trace.Trace("ScrubTo: FROM already a queue; not overridden.");
                }
            }
            else
            {
                // Create/Update path: we don't touch FROM
                effectiveFromQueue = existingFromQueue ?? finalQueueRef;
            }

            // Build set of email strings to remove from TO
            var removeEmails = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            if (!string.IsNullOrWhiteSpace(finalQueueEmail))
                removeEmails.Add(NormEmail(finalQueueEmail));

            // Also remove any explicit FROM-party emails
            if (fromList != null)
            {
                foreach (var p in fromList.Entities)
                {
                    var addr = PartyEmailCandidate(p);
                    if (!string.IsNullOrWhiteSpace(addr))
                        removeEmails.Add(NormEmail(addr));
                }
            }

            // Scrub TO list
            var toList = emailSnapshot.GetAttributeValue<EntityCollection>(ATTR_EMAIL_TO);
            if (toList != null && toList.Entities.Count > 0)
            {
                var filtered = new EntityCollection(
                    toList.Entities
                        .Where(p =>
                        {
                            var er = p.GetAttributeValue<EntityReference>("partyid");
                            if (er != null &&
                                effectiveFromQueue != null &&
                                string.Equals(er.LogicalName, ENTITY_QUEUE, StringComparison.OrdinalIgnoreCase) &&
                                er.Id == effectiveFromQueue.Id)
                            {
                                // Remove the queue itself from TO
                                return false;
                            }

                            var candidate = PartyEmailCandidate(p);
                            if (!string.IsNullOrWhiteSpace(candidate) &&
                                removeEmails.Contains(NormEmail(candidate)))
                            {
                                // Remove any recipient whose email matches the sender queue/user emails
                                return false;
                            }

                            return true;
                        })
                        .ToList());

                if (filtered.Entities.Count != toList.Entities.Count)
                {
                    writeBack[ATTR_EMAIL_TO] = filtered;
                    changed = true;
                    trace.Trace("ScrubTo: TO scrubbed. Before={0}, After={1}",
                        toList.Entities.Count, filtered.Entities.Count);
                }
            }

            return changed;
        }

        // ---------------- Helpers ----------------

        private static bool IsOutgoing(Entity email)
        {
            if (email.Attributes.TryGetValue(ATTR_EMAIL_DIRECTION, out var val) && val is bool b && b)
                return true;
            return false;
        }

        /// <summary>
        /// Returns (caseQueueRef, basicQueueRef, basicQueueEmail)
        /// basicQueueRef = DefaultSendingEmail if present, else caseQueueRef
        /// basicQueueEmail = emailaddress of basic queue (if available)
        /// </summary>
        private static (EntityReference caseQueueRef, EntityReference basicQueueRef, string basicQueueEmail)
            ResolveQueues(IOrganizationService svc, Guid caseId, ITracingService trace)
        {
            var incident = svc.Retrieve(ENTITY_INCIDENT, caseId, new ColumnSet(ATTR_INCIDENT_QUEUE));
            var caseQueueRef = incident.GetAttributeValue<EntityReference>(ATTR_INCIDENT_QUEUE);

            if (caseQueueRef == null)
            {
                trace.Trace("ResolveQueues: Incident has no {0}.", ATTR_INCIDENT_QUEUE);
                return (null, null, null);
            }

            trace.Trace("ResolveQueues: CaseQueue={0}", caseQueueRef.Id);

            // incident queue -> default sending basic queue
            var queueRow = svc.Retrieve(ENTITY_QUEUE, caseQueueRef.Id, new ColumnSet(ATTR_QUEUE_DS));
            var dsQueueRef = queueRow.GetAttributeValue<EntityReference>(ATTR_QUEUE_DS);

            var basicQueueRef = dsQueueRef ?? caseQueueRef;

            // get basic queue email (optional)
            string basicQueueEmail = null;
            var basicQueue = svc.Retrieve(ENTITY_QUEUE, basicQueueRef.Id, new ColumnSet(ATTR_QUEUE_EMAIL));
            if (basicQueue.Contains(ATTR_QUEUE_EMAIL) && basicQueue[ATTR_QUEUE_EMAIL] is string s && !string.IsNullOrWhiteSpace(s))
                basicQueueEmail = s.Trim();

            trace.Trace("ResolveQueues: BasicQueue={0}, Email={1}",
                basicQueueRef.Id, basicQueueEmail ?? "(none)");

            return (caseQueueRef, basicQueueRef, basicQueueEmail);
        }

        private static EntityReference GetFromQueueRef(EntityCollection fromList)
        {
            if (fromList == null) return null;

            foreach (var p in fromList.Entities)
            {
                var er = p.GetAttributeValue<EntityReference>("partyid");
                if (er != null && string.Equals(er.LogicalName, ENTITY_QUEUE, StringComparison.OrdinalIgnoreCase))
                    return er;
            }

            return null;
        }

        private static string PartyEmailCandidate(Entity party)
        {
            var addr = party.GetAttributeValue<string>("addressused");
            if (!string.IsNullOrWhiteSpace(addr)) return addr;

            if (party.Attributes.TryGetValue("partyid", out var v) &&
                v is EntityReference er &&
                !string.IsNullOrWhiteSpace(er.Name))
                return er.Name;

            if (party.Attributes.TryGetValue("name", out var n) && n is string s && !string.IsNullOrWhiteSpace(s))
                return s;

            return null;
        }

        private static string NormEmail(string s)
        {
            var str = s ?? string.Empty;
            var m = Regex.Match(str, @"<([^>]+)>");
            var core = m.Success ? m.Groups[1].Value : str;
            return core.Trim().ToLowerInvariant();
        }

        private static Entity MergeWithPreImage(Entity target, Entity pre, string[] attrs)
        {
            if (pre == null) return target;

            var merged = new Entity(target.LogicalName, target.Id);

            foreach (var kv in target.Attributes)
                merged[kv.Key] = kv.Value;

            foreach (var a in attrs)
            {
                if (!merged.Attributes.ContainsKey(a) && pre.Attributes.ContainsKey(a))
                    merged[a] = pre[a];
            }

            return merged;
        }
    }
}
