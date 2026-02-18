########################################################
# main.tf
# Purpose: Define Azure provider, Resource Group, VNet,
#          subnets, NSGs with tiered rules, and a NAT
#          Gateway for private outbound egress.
########################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Use a modern 4.x version for current resources and arguments
      version = "~> 4.0"
    }
  }
}

# Configure the AzureRM provider
provider "azurerm" {
  features {}
}

#############################
# Resource Group definition #
#############################
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.region
  tags     = var.resource_tags
}

##########################
# Virtual Network (VNet) #
##########################
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.resource_tags
}

#############
# Subnets   #
#############
# Web tier subnet. Exposed through Load Balancer or Application Gateway.
resource "azurerm_subnet" "web" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidrs.web]
}

# App tier subnet. Private only. Outbound egress via NAT Gateway.
resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidrs.app]
}

# Data tier subnet. Most restrictive. No inbound from Internet.
resource "azurerm_subnet" "data" {
  name                 = "data-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidrs.data]
}

######################################
# NAT Gateway for private egress     #
# Associates to app and data subnets #
######################################
# Public IP for NAT Gateway (standard, static)
resource "azurerm_public_ip" "nat_pip" {
  name                = "pip-nat-ch17"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.resource_tags
}

# NAT Gateway resource
resource "azurerm_nat_gateway" "ngw" {
  name                = "ngw-ch17"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"
  tags                = var.resource_tags
}

# Link the Public IP to the NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "ngw_pip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.ngw.id
  public_ip_address_id = azurerm_public_ip.nat_pip.id
}

# Associate NAT Gateway to the app subnet for private outbound egress
resource "azurerm_subnet_nat_gateway_association" "app_ngw_assoc" {
  subnet_id      = azurerm_subnet.app.id
  nat_gateway_id = azurerm_nat_gateway.ngw.id
}

# Associate NAT Gateway to the data subnet for private outbound egress
resource "azurerm_subnet_nat_gateway_association" "data_ngw_assoc" {
  subnet_id      = azurerm_subnet.data.id
  nat_gateway_id = azurerm_nat_gateway.ngw.id
}

###########################################
# Network Security Groups and Associations #
# Each subnet gets a dedicated NSG         #
###########################################

# NSG for Web Subnet: allow Internet to HTTP/HTTPS
resource "azurerm_network_security_group" "nsg_web" {
  name                = "nsg-web-ch17"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.resource_tags

  # Allow HTTP and HTTPS inbound from Internet
  dynamic "security_rule" {
    for_each = toset(var.web_allowed_inbound_ports)
    content {
      name                       = "Allow-Web-Inbound-${security_rule.value}"
      priority                   = 100 + security_rule.value
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = tostring(security_rule.value)
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    }
  }

  # Deny all inbound is implied by default rules. Outbound is allowed by default.
}

# Associate NSG to Web Subnet
resource "azurerm_subnet_network_security_group_association" "web_assoc" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.nsg_web.id
}

# NSG for App Subnet: allow inbound only from Web Subnet to the app port
resource "azurerm_network_security_group" "nsg_app" {
  name                = "nsg-app-ch17"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.resource_tags

  security_rule {
    name                       = "Allow-App-Inbound-From-Web"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.app_inbound_port_from_web)
    source_address_prefix      = azurerm_subnet.web.address_prefixes[0]
    destination_address_prefix = "*"
  }

  # Everything else inbound is denied by default. Outbound is allowed by default.
}

# Associate NSG to App Subnet
resource "azurerm_subnet_network_security_group_association" "app_assoc" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}

# NSG for Data Subnet: allow inbound only from App Subnet to DB port
resource "azurerm_network_security_group" "nsg_data" {
  name                = "nsg-data-ch17"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.resource_tags

  security_rule {
    name                       = "Allow-DB-Inbound-From-App"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.db_inbound_port_from_app)
    source_address_prefix      = azurerm_subnet.app.address_prefixes[0]
    destination_address_prefix = "*"
  }
}

# Associate NSG to Data Subnet
resource "azurerm_subnet_network_security_group_association" "data_assoc" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.nsg_data.id
}

#############################
# Helpful Outputs (Optional)#
#############################
output "vnet_id" {
  description = "Resource ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  description = "Map of subnet IDs for web, app, and data"
  value = {
    web  = azurerm_subnet.web.id
    app  = azurerm_subnet.app.id
    data = azurerm_subnet.data.id
  }
}

output "nat_gateway_public_ip" {
  description = "Public IP used by the NAT Gateway for outbound connections"
  value       = azurerm_public_ip.nat_pip.ip_address
}
