##############################################################
# Terraform and Provider Settings
##############################################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.76.0"   # Tested provider version
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
  required_version = ">= 1.6.0"
}

provider "azurerm" {
  features {}
}

##############################################################
# Resource Group
##############################################################
resource "azurerm_resource_group" "rg" {
  name     = "rg-sentinel-demo"
  location = var.location
}

##############################################################
# Azure Storage Account - intentionally missing tags
##############################################################
resource "azurerm_storage_account" "storage" {
  name                     = "stor${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

##############################################################
# Random suffix for global uniqueness
##############################################################
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}
