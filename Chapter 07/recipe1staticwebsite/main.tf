# Create a Resource Group for storage resources
resource "azurerm_resource_group" "rg" {
  name     = "ch7-r1-rg"
  location = var.region
}

# Create an Azure Storage account with static website enabled
resource "azurerm_storage_account" "storage" {
  name                     = "staticwebstoracc"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  static_website {
    index_document     = "index.html"
    error_404_document = "404.html"
  }
}
