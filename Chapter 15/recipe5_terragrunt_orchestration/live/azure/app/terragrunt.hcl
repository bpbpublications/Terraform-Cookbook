terraform {
  source = "../../../modules/azure-app"
}

# Generate the provider block so modules remain provider-agnostic
generate "provider" {
  path      = "provider.azurerm.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
}
EOF
}

# Remote state for Azure using the azurerm backend
# Ensure the storage account, container, and resource group exist
remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "yourtfstateacct"
    container_name       = "tfstate"
    key                  = "azure/app/terraform.tfstate"
  }
}
# Azure backend stores state in a blob container and supports locking.
# You must supply RG, storage account, container, and key. :contentReference[oaicite:1]{index=1}

inputs = {
  az_location          = "eastus"
  app_name             = "tg-app-az"
  azure_container_image = "nginx:latest"
}
