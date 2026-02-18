output "rg_name" {
  value       = module.network.rg_name
  description = "Resource Group for the secure blueprint"
}

output "vnet_name" {
  value       = module.network.vnet_name
  description = "Virtual network name"
}

output "private_vm_name" {
  value       = module.compute.vm_name
  description = "Linux VM deployed without a public IP"
}

output "kv_name" {
  value       = module.secrets.key_vault_name
  description = "Key Vault name"
}

output "secret_uri" {
  value       = module.secrets.secret_uri
  description = "URI of the secret (value is not exposed)"
  sensitive   = true
}
