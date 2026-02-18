output "vnet_id" {
  description = "ID of the created VNet"
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  description = "Map of subnet name to subnet ID"
  value       = { for k, s in azurerm_subnet.subnets : k => s.id }
}
