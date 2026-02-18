provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "ch4-r2-rg"
  location = "westeurope"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "ch4-r2-vnet"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.2.1.0/24"]
}

module "vm" {
  source           = "./modules/vm"
  location         = azurerm_resource_group.rg.location
  rg_name          = azurerm_resource_group.rg.name
  subnet_id        = azurerm_subnet.subnet.id
  vm_name          = "modular-vm"
  vm_size          = "Standard_B1s"
  admin_public_key = file("~/.ssh/id_rsa.pub")
}
