terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# Data source to fetch remote state from the base config
data "terraform_remote_state" "base" {
  backend = "local"
  config = {
    path = "../base/terraform.tfstate"
  }
}

# Use the remote state output to create a new storage account in that RG
resource "azurerm_storage_account" "example" {
  name                     = "remotestatedemo${random_string.suffix.id}"
  resource_group_name      = data.terraform_remote_state.base.outputs.rg_name
  location                 = data.terraform_remote_state.base.outputs.rg_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
