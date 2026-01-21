using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;

namespace RevOps.SolutionPlugins
{
    public class UpdateSolutionCategoriesOnRelationship : IPlugin
    {
        // 🔧 Table + column logical names
        private const string SolutionEntityName = "revops_solution";
        private const string SolutionIdField = "revops_solutionid";
        private const string SolutionTagField = "revops_solutioncategories";   // text field on Solution

        private const string CategoryEntityName = "revops_solutioncategory";
        private const string CategoryIdField = "revops_solutioncategoryid";      // PK of category
        private const string CategoryNameField = "revops_name";                  // primary name column

        // Relationship vs intersect
        private const string RelationshipName = "revops_solution_revops_solutioncategory_revops_solutioncategory"; // schema name
        private const string IntersectEntityName = "revops_solution_revops_solutioncategory";                          // intersect entity

        // Lookup field names on intersect table
        private const string IntersectSolutionField = "revops_solutionid";
        private const string IntersectCategoryField = "revops_solutioncategoryid";

        public void Execute(IServiceProvider serviceProvider)
        {
            var context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            var factory = (IOrganizationServiceFactory)serviceProvider.GetService(typeof(IOrganizationServiceFactory));
            var service = factory.CreateOrganizationService(context.UserId);
            var tracing = (ITracingService)serviceProvider.GetService(typeof(ITracingService));

            tracing.Trace("UpdateSolutionCategoriesOnRelationship: Start. Message={0}", context.MessageName);

            // Only handle Associate / Disassociate
            if (!string.Equals(context.MessageName, "Associate", StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(context.MessageName, "Disassociate", StringComparison.OrdinalIgnoreCase))
            {
                tracing.Trace("Not Associate/Disassociate, exiting.");
                return;
            }

            // Relationship comes in InputParameters["Relationship"]
            if (!context.InputParameters.Contains("Relationship"))
            {
                tracing.Trace("No Relationship in InputParameters, exiting.");
                return;
            }

            string relationshipName;
            var relObj = context.InputParameters["Relationship"];

            if (relObj is Relationship rel)
            {
                relationshipName = rel.SchemaName;
            }
            else
            {
                relationshipName = relObj.ToString();
            }

            tracing.Trace("Relationship from context: {0}", relationshipName);

            if (!string.Equals(relationshipName, RelationshipName, StringComparison.OrdinalIgnoreCase))
            {
                tracing.Trace("Relationship is not {0}, exiting.", RelationshipName);
                return;
            }

            // Determine which Solution is impacted
            Guid solutionId = ResolveSolutionIdFromContext(context, tracing);
            if (solutionId == Guid.Empty)
            {
                tracing.Trace("No solutionId resolved, exiting.");
                return;
            }

            tracing.Trace("Resolved Solution Id: {0}", solutionId);

            try
            {
                // Rebuild categories string for this solution
                string categoriesString = BuildCategoriesString(service, tracing, solutionId);

                // Update the Solution record
                var toUpdate = new Entity(SolutionEntityName, solutionId)
                {
                    [SolutionTagField] = categoriesString
                };

                service.Update(toUpdate);

                tracing.Trace("UpdateSolutionCategoriesOnRelationship: Updated solution {0} with categories: {1}",
                              solutionId, categoriesString ?? "[null]");
            }
            catch (Exception ex)
            {
                tracing.Trace("UpdateSolutionCategoriesOnRelationship: Exception: {0}", ex.ToString());
                throw new InvalidPluginExecutionException("Error in UpdateSolutionCategoriesOnRelationship.", ex);
            }
        }

        private Guid ResolveSolutionIdFromContext(IPluginExecutionContext context, ITracingService tracing)
        {
            Guid solutionId = Guid.Empty;

            if (!context.InputParameters.Contains("Target") ||
                !(context.InputParameters["Target"] is EntityReference target))
            {
                tracing.Trace("Target missing or not EntityReference.");
                return Guid.Empty;
            }

            tracing.Trace("Target: {0} {1}", target.LogicalName, target.Id);

            // If target is the Solution, use that ID
            if (string.Equals(target.LogicalName, SolutionEntityName, StringComparison.OrdinalIgnoreCase))
            {
                solutionId = target.Id;
                tracing.Trace("Solution found as Target: {0}", solutionId);
                return solutionId;
            }

            // Otherwise, look for Solution in RelatedEntities
            if (context.InputParameters.Contains("RelatedEntities") &&
                context.InputParameters["RelatedEntities"] is EntityReferenceCollection relatedEntities &&
                relatedEntities != null && relatedEntities.Count > 0)
            {
                foreach (var er in relatedEntities)
                {
                    tracing.Trace("Related entity: {0} {1}", er.LogicalName, er.Id);
                    if (string.Equals(er.LogicalName, SolutionEntityName, StringComparison.OrdinalIgnoreCase))
                    {
                        solutionId = er.Id;
                        tracing.Trace("Solution found in RelatedEntities: {0}", solutionId);
                        break;
                    }
                }
            }

            return solutionId;
        }

        /// <summary>
        /// Query the intersect table → join category → build "A; B; C".
        /// </summary>
        private string BuildCategoriesString(IOrganizationService service, ITracingService tracing, Guid solutionId)
        {
            tracing.Trace("BuildCategoriesString: solutionId={0}", solutionId);

            // Start from the intersect entity
            var query = new QueryExpression(IntersectEntityName)
            {
                ColumnSet = new ColumnSet(IntersectCategoryField)
            };

            // Only rows for our Solution
            query.Criteria.AddCondition(IntersectSolutionField, ConditionOperator.Equal, solutionId);

            // Join to Category to get the names
            var linkToCategory = new LinkEntity(
                IntersectEntityName,          // from intersect
                CategoryEntityName,           // to category
                IntersectCategoryField,       // intersect.revops_solutioncategoryid
                CategoryIdField,              // revops_solutioncategory (PK on category)
                JoinOperator.Inner)
            {
                Columns = new ColumnSet(CategoryNameField),
                EntityAlias = "cat"
            };

            query.LinkEntities.Add(linkToCategory);

            var result = service.RetrieveMultiple(query);

            var names = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            foreach (var row in result.Entities)
            {
                var aliasKey = "cat." + CategoryNameField;
                if (row.Contains(aliasKey) &&
                    row[aliasKey] is AliasedValue aliased &&
                    aliased.Value is string name &&
                    !string.IsNullOrWhiteSpace(name))
                {
                    names.Add(name.Trim());
                }
            }

            var sorted = names.OrderBy(n => n).ToList();
            var combined = string.Join("; ", sorted);

            tracing.Trace("BuildCategoriesString: built string: {0}", combined ?? "[null]");

            return combined;
        }
    }
}
