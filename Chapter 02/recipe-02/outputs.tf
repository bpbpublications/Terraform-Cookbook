output "resource_group_id" {
  description = "The ID of the created resource group"
  value       = azurerm_resource_group.rg.id
}

output "resource_group_location" {
  description = "The Azure region of the resource group"
  value       = azurerm_resource_group.rg.location
}