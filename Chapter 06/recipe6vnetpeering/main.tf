# Resource Group: A logical container for all network resources in this recipe
resource "azurerm_resource_group" "rg" {
  name     = "ch6-r6-rg"
  location = var.region
}

# Development VNet: Represents a virtual network for the development environment
resource "azurerm_virtual_network" "dev" {
  name                = "vnet-dev"                     # Name of the Dev VNet
  address_space       = ["10.10.0.0/16"]               # IP address space assigned to Dev VNet
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

# Production VNet: Represents a virtual network for the production environment
resource "azurerm_virtual_network" "prod" {
  name                = "vnet-prod"                    # Name of the Prod VNet
  address_space       = ["10.20.0.0/16"]               # IP address space assigned to Prod VNet
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

# Peering from Dev to Prod: Enables Dev VNet to access resources in Prod VNet
resource "azurerm_virtual_network_peering" "dev_to_prod" {
  name                          = "dev-to-prod"                         # Name for this peering relationship
  resource_group_name           = azurerm_resource_group.rg.name
  virtual_network_name          = azurerm_virtual_network.dev.name     # Source VNet
  remote_virtual_network_id     = azurerm_virtual_network.prod.id      # Target VNet
  allow_virtual_network_access  = true                                 # Allow full access to remote VNet resources
}

# Peering from Prod to Dev: Enables Prod VNet to access resources in Dev VNet
resource "azurerm_virtual_network_peering" "prod_to_dev" {
  name                          = "prod-to-dev"                         # Name for this reverse peering
  resource_group_name           = azurerm_resource_group.rg.name
  virtual_network_name          = azurerm_virtual_network.prod.name    # Source VNet
  remote_virtual_network_id     = azurerm_virtual_network.dev.id       # Target VNet
  allow_virtual_network_access  = true                                 # Allow full access to remote VNet resources
}
