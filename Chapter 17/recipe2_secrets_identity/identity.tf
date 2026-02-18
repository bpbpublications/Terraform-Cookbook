############################################################
# identity.tf
# Purpose: Create a User Assigned Managed Identity that
#          application resources can attach to.
############################################################

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.region
  tags     = var.resource_tags
}

resource "azurerm_user_assigned_identity" "app_uami" {
  name                = var.uami_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.resource_tags
}

