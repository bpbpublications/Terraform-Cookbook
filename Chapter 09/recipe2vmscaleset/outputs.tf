# ID of the VM Scale Set
output "vmss_id" {
  description = "Resource ID of the Virtual Machine Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.vmss.id
}

# ID of the autoscale configuration
output "autoscale_setting_id" {
  description = "Resource ID of the autoscale setting"
  value       = azurerm_monitor_autoscale_setting.autoscale.id
}

# Public IP of the Load Balancer
output "lb_public_ip" {
  description = "Public IP address assigned to the load balancer"
  value       = azurerm_public_ip.pip.ip_address
}
