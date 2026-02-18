# Data source to fetch an existing Azure Resource Group by name
data "azurerm_resource_group" "existing" {
  name = var.existing_rg_name
  # We assume this resource group already exists in your subscription.
}
