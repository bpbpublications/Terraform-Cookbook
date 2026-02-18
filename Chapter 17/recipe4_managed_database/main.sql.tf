#####################################################################
# main.sql.tf
# Purpose: Provision Azure SQL logical server and database with
#          zone-redundant Business Critical SKU, add a private
#          endpoint, and persist secrets in Key Vault.
#####################################################################

# Local switch that only disables public access when a private endpoint
# will actually be created (prevents accidental lockout during dev)
locals {
  create_pe = var.enable_private_endpoint && var.vnet_id != "" && var.subnet_id_for_sql_pe != ""
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.region
  tags     = var.resource_tags
}

# Generate a strong SQL admin password
resource "random_password" "sql_admin_password" {
  length           = 24
  special          = true
  override_special = "!@#$%^&*()-_=+"
}

# Random suffix to improve server name uniqueness while keeping it readable
resource "random_string" "suffix" {
  length  = 4
  upper   = false
  numeric = true
  special = false
}

# Effective server name (lowercase only)
locals {
  sql_server_name_effective = "${var.sql_server_name}${random_string.suffix.result}"
}

#########################################
# Azure SQL logical server (private only)
#########################################
resource "azurerm_mssql_server" "sql" {
  name                = local.sql_server_name_effective
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.db_region # CHANGED
  version             = "12.0"

  administrator_login          = "sqladmin"
  administrator_login_password = random_password.sql_admin_password.result
  minimum_tls_version          = "1.2"

  public_network_access_enabled = local.create_pe ? false : true

  tags = var.resource_tags
}


#########################################
# Azure SQL Database (Business Critical)
#########################################
# Business Critical supports zone redundancy
resource "azurerm_mssql_database" "db" {
  name      = var.sql_database_name
  server_id = azurerm_mssql_server.sql.id

  # Business Critical, Gen5, 2 vCores
  sku_name = var.db_sku_name

  # Zone-redundant HA inside the region
  zone_redundant = var.db_zone_redundant

  # Long-term backup retention and PITR defaults are managed by the platform
  # You can add "long_term_retention_policy" blocks if required by policy

  tags = var.resource_tags
}

#########################################
# Private Endpoint and Private DNS (SQL)
#########################################
# Private DNS zone for Azure SQL
resource "azurerm_private_dns_zone" "sql_zone" {
  count               = local.create_pe ? 1 : 0
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.resource_tags

  timeouts {
    create = "30m"
  }
}

# Link DNS zone to your VNet
resource "azurerm_private_dns_zone_virtual_network_link" "sql_zone_link" {
  count                 = local.create_pe ? 1 : 0
  name                  = "sql-zone-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_zone[0].name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.resource_tags

  depends_on = [azurerm_private_dns_zone.sql_zone]
}

# Private endpoint to the SQL logical server
resource "azurerm_private_endpoint" "sql_pe" {
  count               = local.create_pe ? 1 : 0
  name                = "pe-${local.sql_server_name_effective}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = var.subnet_id_for_sql_pe
  tags                = var.resource_tags

  private_service_connection {
    name                           = "sql-conn"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    # Subresource for Azure SQL logical server
    subresource_names    = ["sqlServer"]
    is_manual_connection = false
  }

  # Attach private DNS zone to the endpoint
  private_dns_zone_group {
    name                 = "sql-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_zone[0].id]
  }
}

#########################################
# Store secrets to Key Vault
#########################################
# Persist admin login and password as KV secrets
# and generate a standard ADO-style connection string for applications
resource "azurerm_key_vault_secret" "sql_admin_login" {
  count        = var.key_vault_id != "" ? 1 : 0
  name         = "sql-admin-login"
  value        = "sqladmin"
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "sql_admin_password" {
  count        = var.key_vault_id != "" ? 1 : 0
  name         = "sql-admin-password"
  value        = random_password.sql_admin_password.result
  key_vault_id = var.key_vault_id
}

# Build connection string using the server FQDN and DB name
# Clients inside the VNet will resolve the hostname to a private IP via Private DNS
locals {
  sql_fqdn           = "${azurerm_mssql_server.sql.name}.database.windows.net"
  sql_connection_str = "Server=tcp:${local.sql_fqdn},1433;Initial Catalog=${azurerm_mssql_database.db.name};Persist Security Info=False;User ID=sqladmin;Password=${random_password.sql_admin_password.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}

resource "azurerm_key_vault_secret" "sql_connection_string" {
  count        = var.key_vault_id != "" ? 1 : 0
  name         = "sql-connection-string"
  value        = local.sql_connection_str
  key_vault_id = var.key_vault_id
}
