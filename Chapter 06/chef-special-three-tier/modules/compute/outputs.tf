output "web_vm_nic" {
  value = azurerm_network_interface.nics["web"].id
}

output "app_vm_nic" {
  value = azurerm_network_interface.nics["app"].id
}

output "db_vm_nic" {
  value = azurerm_network_interface.nics["db"].id
}
