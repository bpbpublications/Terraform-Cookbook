resource "azurerm_resource_group" "rg" {
  name     = "rg-ch15-crosscloud"
  location = var.az_location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-ch15-azure"
  address_space       = [var.az_vnet_cidr]
  location            = var.az_location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "workload" {
  name                 = "workload"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.az_subnet_cidr]
}

# Required name for VPN gateway subnet
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.az_gwsubnet_cidr]
}

resource "azurerm_public_ip" "vpn_pip" {
  name                = "pip-azure-vpn"
  location            = var.az_location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "vng" {
  name                = "vng-azure"
  location            = var.az_location
  resource_group_name = azurerm_resource_group.rg.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"

  ip_configuration {
    name                 = "vng-ipcfg"
    public_ip_address_id = azurerm_public_ip.vpn_pip.id
    subnet_id            = azurerm_subnet.gateway.id
  }
}

# Represents the Google side as the remote peer
resource "azurerm_local_network_gateway" "lng_gcp" {
  name                = "lng-gcp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.az_location

  gateway_address = google_compute_address.vpn_ip.address
  address_space   = [var.gcp_vpc_cidr]
}

# Create the IPsec connection
# GatewaySubnet is mandatory for Azure VPN gateways. The connection type is IPsec to a remote device.
resource "azurerm_virtual_network_gateway_connection" "conn" {
  name                       = "conn-azure-gcp"
  location                   = var.az_location
  resource_group_name        = azurerm_resource_group.rg.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vng.id
  local_network_gateway_id   = azurerm_local_network_gateway.lng_gcp.id
  shared_key                 = var.psk
}
