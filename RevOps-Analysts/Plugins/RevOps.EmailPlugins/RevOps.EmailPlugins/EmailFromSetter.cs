using System;
using Microsoft.Xrm.Sdk;

namespace RevOps.EmailPlugins
{
    /// <summary>
    /// Legacy stub for EmailFromSetter.
    /// Kept only to satisfy existing PluginType references in other environments.
    /// No logic. No steps should be registered for this plugin.
    /// </summary>
    public class EmailFromSetter : IPlugin
    {
        public void Execute(IServiceProvider serviceProvider)
        {
            // Intentionally blank.
        }
    }
}
