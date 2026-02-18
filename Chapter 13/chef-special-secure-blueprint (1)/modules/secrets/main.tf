# Key Vault (RBAC model)
resource "azurerm_key_vault" "kv" {
  name                       = replace("${var.resource_prefix}-kv", "-", "")
  location                   = var.location
  resource_group_name        = "${var.resource_prefix}-rg"  # Same RG name used in network module
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  tags                       = var.default_tags

  # Use RBAC instead of legacy access policies
  enable_rbac_authorization = true
}

data "azurerm_client_config" "current" {}

# Seed a secret. Value is created here for demo, but in enterprises this would be rotated externally.
resource "random_password" "db" {
  length  = 20
  special = true
}

resource "azurerm_key_vault_secret" "dbpwd" {
  name         = "db-password"
  value        = random_password.db.result
  key_vault_id = azurerm_key_vault.kv.id
  tags         = var.default_tags

  # Sensitive by default. Avoid outputting value anywhere.
}
