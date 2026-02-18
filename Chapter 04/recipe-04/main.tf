provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "ch4-r4-rg"
  location = "westeurope"
}

module "network" {
  source          = "./modules/network"
  vnet_name       = "linked-vnet"
  subnet_name     = "linked-subnet"
  address_space   = ["10.10.0.0/16"]
  subnet_prefixes = ["10.10.1.0/24"]
  rg_name         = azurerm_resource_group.rg.name
  location        = azurerm_resource_group.rg.location
}

module "compute" {
  source     = "./modules/compute"
  rg_name    = azurerm_resource_group.rg.name
  location   = azurerm_resource_group.rg.location
  subnet_id  = module.network.subnet_id
}