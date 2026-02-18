output "vm_id" {
  description = "VM resource ID"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "nic_id" {
  description = "NIC resource ID"
  value       = azurerm_network_interface.nic.id
}
