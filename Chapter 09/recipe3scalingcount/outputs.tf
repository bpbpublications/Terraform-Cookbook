# File: outputs.tf

output "app_service_names" {
  description = "List of deployed App Service names"
  value       = [for a in azurerm_app_service.app : a.name]
}

output "app_service_default_sites" {
  description = "Default hostnames for each App Service"
  value       = [for a in azurerm_app_service.app : a.default_site_hostname]
}
