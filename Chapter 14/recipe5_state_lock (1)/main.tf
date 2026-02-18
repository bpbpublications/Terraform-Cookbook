provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "failedapply-rg"
  location = "East US"
}

resource "azurerm_storage_account" "st1" {
  name                     = "uniquestorageacct99999"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "st2" {
  name                     = "uniquestorageacct88888"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}