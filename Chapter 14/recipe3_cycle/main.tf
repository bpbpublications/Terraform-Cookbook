provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "cycle-rg"
  location = "East US"
}

resource "azurerm_storage_account" "st" {
  name                     = "cyclest${random_integer.rand.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_integer" "rand" {
  min = 10000
  max = 99999

  # Intentional cycle: storage account depends on this,
  # but here we make the random number depend on the storage account.
  keepers = {
    rg = azurerm_storage_account.st.id
  }
}
