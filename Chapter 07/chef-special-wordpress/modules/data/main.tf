resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.region
}

resource "azurerm_storage_account" "storage" {
  name                     = "wpstorage${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "media" {
  name                  = "media"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

resource "azurerm_mysql_flexible_server" "db" {
  name                   = "wordpress-db"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = var.region
  administrator_login    = "adminuser"
  administrator_password = var.db_password
  sku_name               = "B_Standard_B1ms"
  version                = "8.0.21"
  zone                   = "1"
  storage {
    size_gb = 20
  }
}