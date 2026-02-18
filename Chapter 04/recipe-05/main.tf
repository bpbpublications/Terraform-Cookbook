provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "ch4-r5-rg"
  location = "westeurope"
}

locals {
  envs = ["dev", "qa", "prod"]
}

module "vnet" {
  count         = length(local.envs)
  source        = "./modules/network"
  env           = local.envs[count.index]
  address_space = ["10.${count.index}.0.0/16"]
  location      = azurerm_resource_group.rg.location
  rg_name       = azurerm_resource_group.rg.name
}