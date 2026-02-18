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

resource "azurerm_resource_group" "log_demo" {
  name     = "demo-localexec-rg"
  location = var.location
}

resource "azurerm_storage_account" "log_demo" {
  name                     = "tflextlog${random_string.suffix.id}"
  resource_group_name      = azurerm_resource_group.log_demo.name
  location                 = azurerm_resource_group.log_demo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Generate a random suffix for unique storage account name
resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

# Null resource to run a local script after storage account creation
resource "null_resource" "post_deploy" {
  triggers = {
    storage_account_name = azurerm_storage_account.log_demo.name
    resource_group       = azurerm_resource_group.log_demo.name
  }
  provisioner "local-exec" {
    command = "echo Deployed storage account ${azurerm_storage_account.log_demo.name} in RG ${azurerm_resource_group.log_demo.name} >> deploy_log.txt"
  }
}
