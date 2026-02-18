############################################
# main.tf
# - Creates a resource group and a storage account
# - You will change something in the Azure Portal to create drift
# - Then run terraform plan to detect and reconcile
############################################

# Caller context (helps with informative outputs)
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-drift-demo"
  location = var.location
  tags     = var.tags
}

# A small random suffix so SA name is unique
resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  special = false
  # Use 'numeric' only; 'number' is deprecated in random v3.x
  numeric = true
}

# Storage Account
# Baseline: public network access ENABLED (true) so the planned state is clear.
# We will flip this in the portal to simulate drift and then reconcile.
resource "azurerm_storage_account" "sa" {
  # SA names must be globally unique and lowercase 3–24 chars
  name                     = "drift${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Default secure settings
  min_tls_version               = "TLS1_2"
  https_traffic_only_enabled    = true
  public_network_access_enabled = true

  tags = var.tags
}
