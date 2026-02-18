provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "plan_demo" {
  name     = "plan-demo-rg"
  location = "East US"
}