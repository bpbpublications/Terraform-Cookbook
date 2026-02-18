############################################################
# outputs.tf
# Purpose: Expose values that later recipes will consume.
############################################################

output "key_vault_id" {
  description = "Resource ID of Key Vault"
  value       = azurerm_key_vault.kv.id
}

output "key_vault_uri" {
  description = "Vault URI used by applications and SDKs"
  value       = azurerm_key_vault.kv.vault_uri
}

output "db_password_secret_id" {
  description = "Resource ID of the db-password secret"
  value       = azurerm_key_vault_secret.db_password.id
}

output "db_connection_string_secret_id" {
  description = "Resource ID of the db-connection-string secret"
  value       = azurerm_key_vault_secret.db_connection_string.id
}

output "uami_id" {
  description = "Resource ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.app_uami.id
}

output "uami_client_id" {
  description = "Client ID for MSI assignment on compute resources"
  value       = azurerm_user_assigned_identity.app_uami.client_id
}

output "uami_principal_id" {
  description = "Principal ID used for access policies and role assignments"
  value       = azurerm_user_assigned_identity.app_uami.principal_id
}
