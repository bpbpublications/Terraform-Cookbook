# Create a resource group to contain all network resources
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.region
}

# Create a virtual network with the specified address space
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

# Create multiple subnets within the virtual network using a map
# If the subnet is named "gateway", use the required name "GatewaySubnet" for VPN compatibility
resource "azurerm_subnet" "subnets" {
  for_each             = var.subnet_map
  name                 = each.key == "gateway" ? "GatewaySubnet" : "${each.key}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}

# Allocate a static public IP address for outbound NAT gateway access
resource "azurerm_public_ip" "nat" {
  name                = "nat-ip"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create a NAT Gateway to enable secure outbound internet access from private subnets
resource "azurerm_nat_gateway" "natgw" {
  name                = "nat-gateway"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"
}

# Associate the previously created public IP with the NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "nat_ip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

# Associate the NAT Gateway only with non-web and non-gateway subnets
# This ensures outbound access is available to internal app and DB subnets only
resource "azurerm_subnet_nat_gateway_association" "nat_assoc" {
  for_each       = { for k, v in var.subnet_map : k => v if k != "web" && k != "gateway" }
  subnet_id      = azurerm_subnet.subnets[each.key].id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}
