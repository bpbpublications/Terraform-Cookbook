# main.dr.tf file
############################################
# Locals
############################################
locals {
  common_tags = {
    project     = var.project
    owner       = var.owner
    environment = var.environment
  }
}

############################################
# Data lookups for existing resources
############################################

data "azurerm_virtual_network" "core" {
  name                = var.core_vnet_name
  resource_group_name = var.core_vnet_rg_name
}

data "azurerm_subnet" "data" {
  name                 = var.data_subnet_name
  virtual_network_name = data.azurerm_virtual_network.core.name
  resource_group_name  = var.core_vnet_rg_name
}

# Primary SQL Server created in Recipe 4 (lookup by name + RG)
data "azurerm_mssql_server" "primary" {
  name                = var.primary_sql_server_name
  resource_group_name = var.primary_rg_name
}

# Primary database created in Recipe 4, used to attach to the Failover Group
data "azurerm_mssql_database" "primary_db" {
  name      = var.primary_database_name
  server_id = data.azurerm_mssql_server.primary.id
}

# Key Vault and secrets for SQL admin (created in Recipe 2)
data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_rg_name
}

# Use this everywhere you previously referenced the vault id
locals {
  key_vault_id = data.azurerm_key_vault.kv.id
}


data "azurerm_key_vault_secret" "sql_admin_login" {
  name         = "sql-admin-login"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  key_vault_id = data.azurerm_key_vault.kv.id
}

############################################
# DR resource group in a different region
############################################
resource "azurerm_resource_group" "dr_rg" {
  name     = var.dr_rg_name
  location = var.dr_location
  tags     = local.common_tags
}

############################################
# Secondary SQL Server in DR region
############################################
resource "azurerm_mssql_server" "secondary_sql" {
  # Unique name with short random suffix to avoid collisions
  name                          = "sqlsvr-ch17-dr-${random_string.suffix.result}"
  resource_group_name           = azurerm_resource_group.dr_rg.name
  location                      = azurerm_resource_group.dr_rg.location
  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false

  administrator_login = data.azurerm_key_vault_secret.sql_admin_login.value
  # Use the write-only field to avoid storing the password in state where supported by the provider
  administrator_login_password_wo         = data.azurerm_key_vault_secret.sql_admin_password.value
  administrator_login_password_wo_version = var.sql_admin_password_version

  tags = local.common_tags
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

############################################
# Private Endpoint for the secondary SQL Server (same hub VNet)
# This is cross-region and supported for SQL Private Link.
############################################
resource "azurerm_private_endpoint" "secondary_sql_pe" {
  name                = "pe-${azurerm_mssql_server.secondary_sql.name}"
  location            = data.azurerm_virtual_network.core.location # <- must match VNet region
  resource_group_name = azurerm_resource_group.dr_rg.name
  subnet_id           = data.azurerm_subnet.data.id # <- avoids hard-coded IDs

  private_service_connection {
    name                           = "sql-conn-secondary"
    private_connection_resource_id = azurerm_mssql_server.secondary_sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sql-zone-group"
    private_dns_zone_ids = [var.sql_private_dns_zone_id]
  }

  tags = local.common_tags
}


############################################
# Failover Group between primary and secondary servers
# Requires the partner_server block and failover policy.
############################################
resource "azurerm_mssql_failover_group" "fog" {
  name      = var.failover_group_name
  server_id = data.azurerm_mssql_server.primary.id

  # Attach the primary database by its ID
  databases = [data.azurerm_mssql_database.primary_db.id]

  # The partner (secondary) SQL server
  partner_server {
    id = azurerm_mssql_server.secondary_sql.id
  }

  # Read-write listener policy
  read_write_endpoint_failover_policy {
    mode          = var.rw_mode          # Automatic or Manual
    grace_minutes = var.rw_grace_minutes # minutes before auto-failover
  }

  # Enable read-only listener failover as a simple on/off flag
  readonly_endpoint_failover_policy_enabled = var.readonly_failover_enabled

  tags = local.common_tags
}
