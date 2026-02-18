# ------------------------------------------------------------------
# Locals block: evaluated once and reused throughout the config.
# ------------------------------------------------------------------
locals {
  prefix          = "${var.env}-${var.app}"                       # dev-payments
  storage_name    = lower(replace(local.prefix, "-", ""))        # devpayments (24 chars max)
  vnet_name       = "vnet-${local.prefix}"                        # vnet-dev-payments
  subnet_name     = "subnet-${var.env}"                           # subnet-dev
}

# Resource Group named after the prefix
resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.prefix}"
  location = var.location
}

# Storage Account using calculated name (must be lower case, 3–24 chars)
resource "azurerm_storage_account" "sa" {
  name                     = local.storage_name
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Virtual Network and Subnet also reuse the prefix
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.70.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.70.1.0/24"]
}