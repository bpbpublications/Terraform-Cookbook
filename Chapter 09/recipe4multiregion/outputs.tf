output "resource_group_name" {
  description = "Name of the resource group deployed by the common module"
  value       = module.common.resource_group_name
}

output "vm_private_ip" {
  description = "Private IP address of the VM deployed by the common module"
  value       = module.common.vm_private_ip
}
