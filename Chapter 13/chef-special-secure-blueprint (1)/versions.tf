# Terraform and providers with safe constraints for team use
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"           # Tested with 4.40.x
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

# AzureRM provider
# Tip: Leave provider registration at default to avoid deprecation warnings.
# If your tenant forbids provider registration, set:
#   resource_provider_registrations = "disabled"
provider "azurerm" {
  features {}
  # resource_provider_registrations = "disabled"  # uncomment only if required by your governance
}
