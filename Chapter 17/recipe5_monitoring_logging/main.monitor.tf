#####################################################################
# main.monitor.tf
# Purpose: Deploy Log Analytics and Application Insights, connect
#          platform metrics from key resources, and configure alerts.
#####################################################################

# Resource Group for monitoring services
resource "azurerm_resource_group" "monitor_rg" {
  name     = var.monitor_rg_name
  location = var.region
  tags     = var.resource_tags
}

# Central Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = var.workspace_name
  location            = azurerm_resource_group.monitor_rg.location
  resource_group_name = azurerm_resource_group.monitor_rg.name

  # PerGB2018 is the standard SKU for most production scenarios
  sku               = "PerGB2018"
  retention_in_days = 30

  tags = var.resource_tags
}

# Workspace-based Application Insights (unified with the workspace)
resource "azurerm_application_insights" "appi" {
  name                = var.app_insights_name
  location            = azurerm_resource_group.monitor_rg.location
  resource_group_name = azurerm_resource_group.monitor_rg.name

  application_type = "web"

  # Link to Log Analytics Workspace (workspace-based Application Insights)
  workspace_id = azurerm_log_analytics_workspace.law.id

  # Optional hardening toggles (leave defaults if unsure)
  # internet_ingestion_enabled = true
  # internet_query_enabled     = true
  # local_authentication_disabled = true

  tags = var.resource_tags
}

##############################
# Diagnostic settings (metrics)
# Send platform metrics to Log Analytics for correlation and dashboards.
##############################

# Diagnostic settings for Internal Load Balancer
# Use the resource ID from variables, and new enabled_* blocks
resource "azurerm_monitor_diagnostic_setting" "lb_diag" {
  count                      = var.lb_id == "" ? 0 : 1
  name                       = "diag-lb"
  target_resource_id         = var.lb_id # FIXED: was azurerm_lb.ilb.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  # Your LB exposes a Logs category named "LoadBalancerHealthEvent"
  # (you confirmed with az monitor diagnostic-settings categories list)
  enabled_log {
    category = "LoadBalancerHealthEvent"
  }

  # Metrics category is "AllMetrics" for LB
  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic settings for VM Scale Set
resource "azurerm_monitor_diagnostic_setting" "vmss_diag" {
  count                      = var.vmss_id == "" ? 0 : 1
  name                       = "diag-vmss"
  target_resource_id         = var.vmss_id # FIXED: was azurerm_linux_virtual_machine_scale_set.app_vmss.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  # VMSS exposes Metrics only in your listing; enable AllMetrics
  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic settings for SQL Database
resource "azurerm_monitor_diagnostic_setting" "sqldb_diag" {
  count                      = var.sql_database_id == "" ? 0 : 1
  name                       = "diag-sqldb"
  target_resource_id         = var.sql_database_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  # Your SQL resource exposes Metrics category "AllMetrics"
  enabled_metric {
    category = "AllMetrics"
  }
}

##############################
# Action Group for notifications
##############################

resource "azurerm_monitor_action_group" "ops_email" {
  name                = "ag-ch17-ops-email"
  resource_group_name = azurerm_resource_group.monitor_rg.name
  short_name          = "opsag"

  email_receiver {
    name                    = "ops-email"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }

  tags = var.resource_tags
}

##############################
# Metric Alerts
##############################

# Alert: VMSS average CPU > 80% over 5 minutes
resource "azurerm_monitor_metric_alert" "vmss_cpu_high" {
  count                    = var.vmss_id == "" ? 0 : 1
  name                     = "alert-vmss-cpu-high"
  resource_group_name      = azurerm_resource_group.monitor_rg.name
  scopes                   = [var.vmss_id]
  description              = "Alert when VMSS average CPU exceeds 80% for 5 minutes"
  severity                 = 2      # Sev2
  frequency                = "PT1M" # Evaluate every 1 minute
  window_size              = "PT5M" # Look back 5 minutes
  target_resource_type     = "Microsoft.Compute/virtualMachineScaleSets"
  target_resource_location = var.vmss_region

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops_email.id
  }

  tags = var.resource_tags
}

# Alert: SQL Database CPU > 80% over 5 minutes
resource "azurerm_monitor_metric_alert" "sql_cpu_high" {
  count                    = var.sql_database_id == "" ? 0 : 1
  name                     = "alert-sqldb-cpu-high"
  resource_group_name      = azurerm_resource_group.monitor_rg.name
  scopes                   = [var.sql_database_id]
  description              = "Alert when SQL Database CPU exceeds 80% for 5 minutes"
  severity                 = 2
  frequency                = "PT1M"
  window_size              = "PT5M"
  target_resource_type     = "Microsoft.Sql/servers/databases"
  target_resource_location = var.sql_region

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops_email.id
  }

  tags = var.resource_tags
}

##############################
# Optional: Activity Log Alert on critical delete operations in the subscription.
# Scope this to the monitoring RG for an example with a narrow blast radius.
##############################

resource "azurerm_monitor_activity_log_alert" "critical_delete_in_rg" {
  name                = "alert-activity-delete"
  resource_group_name = azurerm_resource_group.monitor_rg.name
  scopes              = [azurerm_resource_group.monitor_rg.id]
  description         = "Alert on delete operations in the monitoring resource group"
  enabled             = true

  # Required in provider v4
  location = "Global"

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Resources/subscriptions/resourceGroups/delete"
    level          = "Error"
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops_email.id
  }

  tags = var.resource_tags
}

