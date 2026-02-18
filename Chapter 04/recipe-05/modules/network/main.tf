resource "azurerm_virtual_network" "vnet" {
  name                = "${var.env}-vnet"
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.rg_name
}