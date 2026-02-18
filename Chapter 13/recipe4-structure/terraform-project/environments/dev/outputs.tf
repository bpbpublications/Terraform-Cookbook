output "vnet_id" {
  description = "Dev VNet ID"
  value       = module.network.vnet_id
}

output "vm_id" {
  description = "Dev VM ID"
  value       = module.compute.vm_id
}
