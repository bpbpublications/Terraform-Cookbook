# Private DNS zone for Private Link
data "azurerm_resource_group" "rg" {
  name = var.rg_name
}
resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.rg_name
}
resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "postgres-dns-link"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_postgresql_flexible_server" "db" {
  name                   = var.db_name
  location               = var.location
  resource_group_name    = var.rg_name
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  sku_name               = var.sku_name
  version                = "13"
  storage_mb             = var.storage_mb

  # disable public network access when using virtual network
  public_network_access_enabled = false

  delegated_subnet_id    = var.db_subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.postgres.id
}