######################################
# Backend configuration
######################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.76.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-demo"
    storage_account_name = "tfstate629141" # Replace with $stgName
    container_name       = "tfstate"
    key                  = "chapter13/recipe3/terraform.tfstate"
  }
}

######################################
# Provider
######################################
provider "azurerm" {
  features {}
  skip_provider_registration = true # Required if you cannot register providers
}

######################################
# Random suffix to simulate state change
######################################
resource "random_string" "suffix" {
  length  = 6
  lower   = true
  number  = true
  special = false
}
