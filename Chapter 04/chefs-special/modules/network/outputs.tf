output "web_subnet_id" {
  value       = azurerm_subnet.web.id
}
output "app_subnet_id" {
  value       = azurerm_subnet.app.id
}
output "db_subnet_id" {
  value       = azurerm_subnet.db.id
}
output "vnet_id" {
  description = "ID of the created virtual network"
  value       = azurerm_virtual_network.vnet.id
}