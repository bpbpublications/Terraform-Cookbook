resource "azurerm_resource_group" "rg" {
  name     = "legacy-rg"     # Must match the real RG name
  location = "uksouth"       # Any region; will be ignored after import
}

resource "azurerm_storage_account" "legacy" {
  name                = "legacytfstate"      # Must match the actual Storage account name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  account_tier        = "Standard"
  account_replication_type = "LRS"
}
