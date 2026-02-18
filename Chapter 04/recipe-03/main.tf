provider "azurerm" {
  features {}
}

provider "random" {}

resource "azurerm_resource_group" "rg" {
  name     = "ch4-r3-rg"
  location = "westeurope"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "ch4-r3-vnet"
  address_space       = ["10.3.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "r3-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.3.1.0/24"]
}

resource "random_id" "server" {
  byte_length = 8
}

module "vm" {
  source    = "Azure/compute/azurerm"
  version   = "5.3.0"

  resource_group_name = azurerm_resource_group.rg.name
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["demo-vm-${random_id.server.hex}"]
  vnet_subnet_id      = azurerm_subnet.subnet.id
}
