############################################################
# outputs.tf
# Purpose: Expose monitoring endpoints and IDs.
############################################################

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.law.id
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.appi.connection_string
  sensitive = true
}

output "action_group_id" {
  description = "Monitor Action Group ID"
  value       = azurerm_monitor_action_group.ops_email.id
}
