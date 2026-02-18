############################################################
# keyvault.tf
# Purpose: Provision Key Vault, add secrets, and grant
#          least-privilege secret read to the UAMI.
############################################################

# Tenant details for Key Vault creation
data "azurerm_client_config" "current" {}

# Strong secret for DB password
resource "random_password" "db_password" {
  length  = 20
  special = true
  # Use the correct argument name for custom special characters
  override_special = "!@#$%^&*()-_=+"
}

# Azure Key Vault
resource "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                   = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled   = true

  # For private endpoint scenarios, disable public network access.
  public_network_access_enabled = var.enable_private_endpoint ? false : true

  # Baseline access policy for the deploying user (development convenience).
  # In production consider Azure RBAC for KV.
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover", "Backup", "Restore"
    ]
  }

  tags = var.resource_tags
}

# Least-privilege policy for the application identity (read secrets)
resource "azurerm_key_vault_access_policy" "app_read_secrets" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.app_uami.principal_id

  secret_permissions = ["Get", "List"]
}

# Example secrets
resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = random_password.db_password.result
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "db_connection_string" {
  name         = "db-connection-string"
  value        = "Server=tcp:db.ch17.local,1433;Database=appdb;User Id=appuser;Password=${random_password.db_password.result};Encrypt=True;"
  key_vault_id = azurerm_key_vault.kv.id
}
