provider "azurerm" {
  features {}
}

# random_string for unique suffix (storage name must be 3–24 lowercase alphanumeric)
provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

module "storage" {
  source           = "./modules/storage"
  storage_name     = "${var.storage_name}${random_string.suffix.result}"
  rg_name          = azurerm_resource_group.rg.name
  location         = azurerm_resource_group.rg.location
  account_tier     = var.account_tier
  replication_type = var.replication_type
}