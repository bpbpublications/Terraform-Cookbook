output "rg_name" {
  description = "Name of the Resource Group"
  value       = azurerm_resource_group.base_rg.name
}

output "rg_location" {
  description = "Location of the Resource Group"
  value       = azurerm_resource_group.base_rg.location
}
