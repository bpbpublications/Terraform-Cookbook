output "vm_name" {
  value       = azurerm_linux_virtual_machine.vm.name
  description = "Private VM name"
}

output "vm_identity_principal_id" {
  value       = azurerm_linux_virtual_machine.vm.identity[0].principal_id
  description = "Principal ID of the VM system-assigned identity"
}
