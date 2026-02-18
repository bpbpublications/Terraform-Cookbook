resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.region
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnet_map
  name                 = "${each.key}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}
