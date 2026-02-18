terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    # external provider is built-in to Terraform core (no need to declare)
  }
}

provider "azurerm" {
  features {}
}

# External data source to get current public IP (using ipify API)
data "external" "my_ip" {
  program = ["curl", "-s", "https://api.ipify.org?format=json"]
  # curl will output {"ip":"X.X.X.X"} as JSON
}

# Create a Resource Group for the demo (to hold the NSG)
resource "azurerm_resource_group" "demo" {
  name     = "demo-external-api-rg"
  location = var.location
}

# Create a Network Security Group with a rule allowing SSH from our IP
resource "azurerm_network_security_group" "demo_nsg" {
  name                = "demo-extapi-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name
}

resource "azurerm_network_security_rule" "allow_ssh_myip" {
  name                        = "Allow-SSH-MyIP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = data.external.my_ip.result.ip   # allow only my IP
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.demo_nsg.name
  resource_group_name         = azurerm_resource_group.demo.name
}
