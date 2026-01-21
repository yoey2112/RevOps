using System;
using Microsoft.Xrm.Sdk;

namespace RevOps.Plugins.CaseOwnerStamper
{
    public class CaseOwnerStamper : IPlugin
    {
        private const string EntityIncident = "incident";
        private const string AttrOwnerId = "ownerid";

        // Your custom fields
        private const string AttrPreviousOwnerUser = "revops_previousowner";     // lookup -> systemuser
        private const string AttrOwnerAssignedOn = "revops_ownerassignedon";     // datetime

        private const string PreImageName = "PreImage";

        public void Execute(IServiceProvider serviceProvider)
        {
            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));

            if (!string.Equals(context.PrimaryEntityName, EntityIncident, StringComparison.OrdinalIgnoreCase))
                return;

            if (!string.Equals(context.MessageName, "Update", StringComparison.OrdinalIgnoreCase))
                return;

            if (context.Depth > 2)
                return;

            if (!context.InputParameters.Contains("Target"))
                return;

            var target = context.InputParameters["Target"] as Entity;
            if (target == null)
                return;

            // Only run when ownerid is part of this update
            if (!target.Attributes.Contains(AttrOwnerId))
                return;

            var newOwner = target.GetAttributeValue<EntityReference>(AttrOwnerId);
            if (newOwner == null)
                return;

            // PreImage required
            if (context.PreEntityImages == null || !context.PreEntityImages.ContainsKey(PreImageName))
                return;

            var preImage = context.PreEntityImages[PreImageName];
            var oldOwner = preImage.GetAttributeValue<EntityReference>(AttrOwnerId);
            if (oldOwner == null)
                return;

            // No change => do nothing
            if (string.Equals(oldOwner.LogicalName, newOwner.LogicalName, StringComparison.OrdinalIgnoreCase) &&
                oldOwner.Id == newOwner.Id)
                return;

            // Stamp time
            target[AttrOwnerAssignedOn] = context.OperationCreatedOn.ToUniversalTime();

            // Previous owner (user only)
            if (string.Equals(oldOwner.LogicalName, "systemuser", StringComparison.OrdinalIgnoreCase))
            {
                target[AttrPreviousOwnerUser] = new EntityReference("systemuser", oldOwner.Id);
            }
        }
    }
}
