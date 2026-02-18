terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"  # ensure a recent version
    }
  }
}

provider "azurerm" {
  features {}  # AzureRM provider initialization
}
