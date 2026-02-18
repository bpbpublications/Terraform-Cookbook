# Pin Terraform and providers to known good versions for consistent team runs.

terraform {
  required_version = ">= 1.6.0, < 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.76.0"
    }
  }
}

provider "azurerm" {
  features {}
  # In restricted subscriptions set this to true to avoid RP registration attempts
  skip_provider_registration = true
}
