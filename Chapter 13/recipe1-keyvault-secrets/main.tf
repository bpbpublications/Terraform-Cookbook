##############################################################
# Providers and versions
##############################################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.76.0"          # Tested provider version
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

##############################################################
# AzureRM provider
# - skip_provider_registration helps in restricted subscriptions
##############################################################
provider "azurerm" {
  features {}
  skip_provider_registration = true  # Set to false if you can register RPs
}

##############################################################
# Caller context (your signed-in identity)
##############################################################
data "azurerm_client_config" "current" {}

##############################################################
# Resource Group
##############################################################
resource "azurerm_resource_group" "rg" {
  name     = "rg-keyvault-demo"
  location = var.location
}

##############################################################
# Random suffix for globally-unique Key Vault name
##############################################################
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

##############################################################
# Key Vault in RBAC mode (no access policies)
# - purge_protection_enabled: compliance & safety
# - enable_rbac_authorization: switch to RBAC for data-plane
##############################################################
resource "azurerm_key_vault" "kv" {
  name                = "kv-demo-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled  = true
  enable_rbac_authorization = true

  # Optional hardening:
  # public_network_access_enabled = false
  # network_acls {
  #   default_action = "Deny"
  #   bypass         = "AzureServices"
  #   ip_rules       = ["<your-ip/32>"]
  # }
}

##############################################################
# RBAC: grant Secrets Officer on the vault to your identity
# - Allows Get/Set/List/Delete secrets (data-plane)
# - Requires Owner or User Access Administrator at scope
##############################################################
resource "azurerm_role_assignment" "kv_secrets_officer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

##############################################################
# Seed a secret (example only; in CI/CD inject value securely)
##############################################################
resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = "SuperSecret123!"           # Placeholder; replace with pipeline-injected value
  key_vault_id = azurerm_key_vault.kv.id

  # Ensure RBAC role is active before trying to Set/Get the secret
  depends_on = [azurerm_role_assignment.kv_secrets_officer]
}

##############################################################
# Read secret at apply time (data source)
##############################################################
data "azurerm_key_vault_secret" "retrieved_password" {
  name         = azurerm_key_vault_secret.db_password.name
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_role_assignment.kv_secrets_officer]
}

##############################################################
# Output masked
##############################################################
output "db_password" {
  value     = data.azurerm_key_vault_secret.retrieved_password.value
  sensitive = true
}
