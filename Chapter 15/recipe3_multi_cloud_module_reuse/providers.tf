terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = ">= 4.0.0" }
    google  = { source = "hashicorp/google", version = ">= 7.0.0" }
  }
}

# Azure provider. Authenticate with Azure CLI or a Service Principal.
# The features block must be present and must be a block.
provider "azurerm" {
  alias = "az"
  features {}
  # If Terraform later complains that subscription_id is required, either
  # set it here or select the subscription with Azure CLI first.
  # subscription_id = "<your-subscription-id>"
}

# Google provider. Authenticate with Application Default Credentials or a key file.
provider "google" {
  alias   = "gcp"
  project = var.gcp_project
  region  = var.gcp_region
}
