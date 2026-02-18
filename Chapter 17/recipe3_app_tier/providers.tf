########################################################
# providers.tf
# Purpose: Pin providers and configure AzureRM provider.
########################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Use 4.x for modern resources. If pinned to 3.x in your lock file, set "~> 3.117".
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}
