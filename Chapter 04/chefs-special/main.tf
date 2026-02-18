provider "azurerm" {
  features {}
}
# Use random suffix to ensure unique PostgreSQL server name
provider "random" {}
resource "random_string" "db_suffix" {
  length  = 6
  upper   = false
  numeric = true
  special = false
}
resource "azurerm_resource_group" "rg" {
  name     = "three-tier-rg"
  location = "westeurope"
}
module "network" {
  source        = "./modules/network"
  vnet_name     = "app-vnet"
  address_space = ["10.0.0.0/16"]
  rg_name       = azurerm_resource_group.rg.name
  location      = azurerm_resource_group.rg.location
}
module "compute" {
  source           = "./modules/compute"
  rg_name          = azurerm_resource_group.rg.name
  location         = azurerm_resource_group.rg.location
  app_subnet_id    = module.network.app_subnet_id
  admin_public_key = file("~/.ssh/id_rsa.pub")
  vm_count         = 2
}
module "database" {
  source           = "./modules/database"
  rg_name          = azurerm_resource_group.rg.name
  location         = azurerm_resource_group.rg.location
  vnet_id          = module.network.vnet_id
  db_subnet_id     = module.network.db_subnet_id
  # combine prefix with random suffix for a unique name
  db_name          = "${var.db_name_prefix}${random_string.db_suffix.result}"
  admin_username   = var.db_admin
  admin_password   = var.db_password
}