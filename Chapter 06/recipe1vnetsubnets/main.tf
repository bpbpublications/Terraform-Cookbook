# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "ch6-r1-rg"
  location = var.region
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "ch6-r1-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

# Public Subnet
resource "azurerm_subnet" "public" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

# Private Subnet
resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.2.0/24"]
}

# Public IP for NAT Gateway
resource "azurerm_public_ip" "nat_ip" {
  name                = "nat-ip"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NAT Gateway
resource "azurerm_nat_gateway" "nat" {
  name                = "nat-gateway"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"
}

# Associate Public IP with NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "nat_ip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat_ip.id
}

# Associate NAT Gateway with Private Subnet
resource "azurerm_subnet_nat_gateway_association" "private_nat" {
  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}
