output "key_vault_name" {
  value       = azurerm_key_vault.kv.name
  description = "Key Vault name"
}

output "key_vault_id" {
  value       = azurerm_key_vault.kv.id
  description = "Key Vault resource ID"
}

# Pass only the URI to workloads. Value never leaves Key Vault.
output "secret_uri" {
  value       = azurerm_key_vault_secret.dbpwd.id
  description = "Full secret URI"
  sensitive   = true
}
