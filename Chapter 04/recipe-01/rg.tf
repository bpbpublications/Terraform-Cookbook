provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "ch4-r1-rg"
  location = "westeurope"
}
