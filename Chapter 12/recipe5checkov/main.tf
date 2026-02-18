provider "azurerm" {
  features {}
}

resource "azurerm_network_security_group" "insecure" {
  name                = "example-nsg"
  location            = "East US"
  resource_group_name = "example-rg"

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }
}