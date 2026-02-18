#################################################################
# private_endpoint.tf
# Purpose: Optional Key Vault Private Endpoint and Private DNS.
#################################################################

locals {
  create_pe = var.enable_private_endpoint && var.vnet_id != "" && var.subnet_id_for_kv_pe != ""
}

# Private DNS zone for Key Vault Private Link
resource "azurerm_private_dns_zone" "kv_zone" {
  count               = local.create_pe ? 1 : 0
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.resource_tags
}

# Link the DNS zone to your VNet
resource "azurerm_private_dns_zone_virtual_network_link" "kv_zone_link" {
  count                 = local.create_pe ? 1 : 0
  name                  = "kv-zone-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kv_zone[0].name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.resource_tags
}

# Private Endpoint for Key Vault with nested DNS zone group
resource "azurerm_private_endpoint" "kv_pe" {
  count               = local.create_pe ? 1 : 0
  name                = "pe-${var.key_vault_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = var.subnet_id_for_kv_pe
  tags                = var.resource_tags

  private_service_connection {
    name                           = "kv-conn"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  # Use the nested block instead of a separate resource
  private_dns_zone_group {
    name                 = "kv-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv_zone[0].id]
  }
}
