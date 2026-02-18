#####################################################################
# variables.tf
# Purpose: Centralize inputs for monitoring resources and targets.
#####################################################################

# Region and Resource Group where the monitoring resources will live.
# Choose the same region as your core network or any governance-approved region.
variable "region" {
  type        = string
  description = "Azure region for Log Analytics and Application Insights"
  default     = "eastus"
}

variable "monitor_rg_name" {
  type        = string
  description = "Resource Group for monitoring resources"
  default     = "rg-ch17-monitoring"
}

# Names for the monitoring resources
variable "workspace_name" {
  type        = string
  description = "Log Analytics Workspace name"
  default     = "law-ch17"
}

variable "app_insights_name" {
  type        = string
  description = "Application Insights component name"
  default     = "appi-ch17"
}

# Resource IDs of the targets to monitor.
# Fetch these from previous recipes or Azure CLI and paste into dev.tfvars.
variable "vmss_id" {
  type        = string
  description = "Resource ID of the application VM Scale Set"
  default     = "" # Example: "/subscriptions/.../Microsoft.Compute/virtualMachineScaleSets/vmss-ch17-app"
}

variable "vmss_region" {
  type        = string
  description = "Region of the VM Scale Set (used by metric alerts)"
  default     = "eastus"
}

variable "lb_id" {
  type        = string
  description = "Resource ID of the internal Load Balancer"
  default     = "" # Example: "/subscriptions/.../Microsoft.Network/loadBalancers/ilb-ch17-app"
}

variable "sql_database_id" {
  type        = string
  description = "Resource ID of the Azure SQL Database to monitor"
  default     = "" # Example: "/subscriptions/.../Microsoft.Sql/servers/<server>/databases/appdb"
}

variable "sql_region" {
  type        = string
  description = "Region of the SQL Database (used by metric alerts)"
  default     = "eastus2"
}

# Alerting
variable "alert_email" {
  type        = string
  description = "Email address to receive alert notifications"
  default     = "ops@example.com"
}

# Tags for governance and cost allocation
variable "resource_tags" {
  type        = map(string)
  description = "Tags applied to all monitoring resources"
  default = {
    project     = "terraform-cookbook-capstone"
    environment = "dev"
    owner       = "platform-engineering"
  }
}
