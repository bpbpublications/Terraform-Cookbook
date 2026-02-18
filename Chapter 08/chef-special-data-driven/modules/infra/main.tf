resource "azurerm_virtual_network" "vnets" {
  for_each            = toset(var.environments)
  name                = "vnet-${each.key}"
  address_space       = ["10.${100 + index(var.environments, each.key)}.0.0/16"]
  location            = var.region
  resource_group_name = var.rg_name
}

resource "azurerm_subnet" "subnets" {
  for_each             = azurerm_virtual_network.vnets
  name                 = "subnet-${each.key}"
  resource_group_name  = var.rg_name
  virtual_network_name = each.value.name
  address_prefixes     = ["10.${100 + index(var.environments, each.key)}.1.0/24"]
}