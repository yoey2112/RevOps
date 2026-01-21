using System;
using Microsoft.Xrm.Sdk;

namespace RevOps.Plugins.EmailWorkflowMarker
{
    /// <summary>
    /// Email Create PreOperation:
    /// - If Subject starts with "[WF]" (exactly at position 0),
    ///   set email.isworkflowcreated = true and strip the marker + trim leading spaces.
    /// </summary>
    public class EmailWorkflowMarker : IPlugin
    {
        private const string Marker = "[WF]";

        public void Execute(IServiceProvider serviceProvider)
        {
            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            var tracing = (ITracingService)serviceProvider.GetService(typeof(ITracingService));

            if (!context.InputParameters.Contains("Target") || !(context.InputParameters["Target"] is Entity))
            {
                tracing.Trace("No Target entity in context; exiting.");
                return;
            }

            var target = (Entity)context.InputParameters["Target"];


            if (!string.Equals(target.LogicalName, "email", StringComparison.OrdinalIgnoreCase))
            {
                tracing.Trace($"Unexpected entity {target.LogicalName}; exiting.");
                return;
            }

            // We only intend to run on Create/PreOperation, but keep it safe.
            if (!string.Equals(context.MessageName, "Create", StringComparison.OrdinalIgnoreCase))
            {
                tracing.Trace($"Unexpected message {context.MessageName}; exiting.");
                return;
            }

            // Subject may be null on create.
            var subject = target.GetAttributeValue<string>("subject") ?? string.Empty;

            // Must match exactly at the very start.
            if (!subject.StartsWith(Marker, StringComparison.Ordinal))
            {
                tracing.Trace("Subject does not start with [WF]; no action taken.");
                return;
            }

            // Stamp flag
            target["isworkflowcreated"] = true;

            // Strip marker and trim any extra leading spaces.
            var stripped = subject.Substring(Marker.Length).TrimStart();

            // Allow blank.
            target["subject"] = stripped;

            tracing.Trace("Stamped isworkflowcreated=true and stripped [WF] marker from subject.");
        }
    }
}
