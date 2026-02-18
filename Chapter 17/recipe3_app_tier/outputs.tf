############################################################
# outputs.tf
# Purpose: Expose useful values for validation and wiring.
############################################################

output "ilb_private_ip" {
  description = "Private IP of the internal Load Balancer frontend"
  value       = azurerm_lb.ilb.frontend_ip_configuration[0].private_ip_address
}

output "vmss_id" {
  description = "Resource ID of the application VM Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.app_vmss.id
}

output "vmss_identity_ids" {
  description = "Attached User Assigned Managed Identity IDs"
  value       = azurerm_linux_virtual_machine_scale_set.app_vmss.identity[0].identity_ids
}
