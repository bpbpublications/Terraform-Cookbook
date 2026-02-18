terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  # We explicitly set the backend to local (default) with a known path for state
  backend "local" {
    path = "terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "base_rg" {
  name     = "remote-state-base-rg"
  location = var.location
}
