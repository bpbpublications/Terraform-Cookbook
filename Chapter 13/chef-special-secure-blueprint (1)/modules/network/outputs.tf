output "rg_name"       { value = azurerm_resource_group.rg.name }
output "vnet_name"     { value = azurerm_virtual_network.vnet.name }
output "app_subnet_id" { value = azurerm_subnet.app.id }
output "app_nsg_id"    { value = azurerm_network_security_group.app.id }
