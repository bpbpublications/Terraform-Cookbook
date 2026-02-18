# 1) Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "ch7-r5-rg"
  location = var.region
}

# 2) Cosmos DB account (SQL API / Core)
resource "azurerm_cosmosdb_account" "cosmos" {
  name                = var.account_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = var.consistency_level
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }

  free_tier_enabled          = true
  analytical_storage_enabled = true
}

# 3) SQL Database with its own 400 RU/s
resource "azurerm_cosmosdb_sql_database" "db" {
  name                = var.database_name
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  throughput          = var.db_throughput
}

# 4) SQL Container (shares the DB’s throughput)
resource "azurerm_cosmosdb_sql_container" "container" {
  name                = var.container_name
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  database_name       = azurerm_cosmosdb_sql_database.db.name

  partition_key_path = var.partition_key_path
  partition_key_kind = "Hash"

  indexing_policy {
    indexing_mode = "consistent"
  }
}
