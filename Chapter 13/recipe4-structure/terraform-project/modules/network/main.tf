# This module expects RG to exist in the environment layer.
# It creates a VNet plus one subnet per entry.

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-main"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnet_cidrs
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}

# Optional NSG per subnet could be added here or exposed as another module.
