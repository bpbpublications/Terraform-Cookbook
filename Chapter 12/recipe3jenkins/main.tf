provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "jenkins" {
  name     = "jenkins-rg"
  location = "East US"
}