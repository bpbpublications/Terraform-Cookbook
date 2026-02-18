# Resource group for the NSG
resource "azurerm_resource_group" "rg" {
  name     = "rg-ch10-r4"
  location = var.location
}

# -------------------------------------------------------------------
# Network Security Group with dynamic security_rule blocks
# -------------------------------------------------------------------
resource "azurerm_network_security_group" "web_nsg" {
  name                = "nsg-web"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  # One security_rule block per element in var.rules
  dynamic "security_rule" {
    for_each = var.rules
    content {
      name                       = security_rule.value.name
      priority                   = 100 + index(var.rules, security_rule.value)
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      source_port_range           = "*"
      destination_port_range     = security_rule.value.port
    }
  }
}

# Optional: Create a test subnet and associate the NSG to verify rules
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-dynamic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.60.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.60.1.0/24"]
     }