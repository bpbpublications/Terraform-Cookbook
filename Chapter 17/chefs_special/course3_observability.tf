############################################
# Log Analytics and workspace-based Application Insights
############################################

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${local.name_suffix}"
  location            = var.location_primary
  resource_group_name = azurerm_resource_group.core.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_application_insights" "appi" {
  name                = "appi-${local.name_suffix}"
  location            = var.location_primary
  resource_group_name = azurerm_resource_group.core.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id # workspace-based model
  tags                = local.tags
}

############################################
# Diagnostic Settings to Log Analytics
############################################

# Load Balancer diagnostics
resource "azurerm_monitor_diagnostic_setting" "lb_diag" {
  name                       = "diag-lb"
  target_resource_id         = azurerm_lb.ilb.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "LoadBalancerHealthEvent"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# VMSS metrics
resource "azurerm_monitor_diagnostic_setting" "vmss_diag" {
  name                       = "diag-vmss"
  target_resource_id         = azurerm_linux_virtual_machine_scale_set.vmss.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_metric {
    category = "AllMetrics"
  }
}

# SQL Server metrics
resource "azurerm_monitor_diagnostic_setting" "sql_diag" {
  name                       = "diag-sql"
  target_resource_id         = azurerm_mssql_server.sql.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_metric {
    category = "AllMetrics"
  }
}

############################################
# Alerts - metric and activity log
############################################

# Alert if VMSS average CPU is above 80 percent for 5 minutes
resource "azurerm_monitor_metric_alert" "vmss_cpu_high" {
  name                = "alert-vmss-cpu-high"
  resource_group_name = azurerm_resource_group.core.name
  scopes              = [azurerm_linux_virtual_machine_scale_set.vmss.id]
  description         = "Average CPU over 80 percent for 5 minutes"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  auto_mitigate       = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  tags = local.tags
}

# Alert on delete operations in the app RG
resource "azurerm_monitor_activity_log_alert" "critical_delete_in_rg" {
  name                = "alert-critical-delete"
  location            = "Global"
  resource_group_name = azurerm_resource_group.core.name
  description         = "Alert on critical delete operations in the application resource group"
  scopes              = [azurerm_resource_group.app.id]

  criteria {
    category       = "Administrative"
    level          = "Critical"
    operation_name = "Microsoft.Resources/subscriptions/resourcegroups/delete"
  }
}


