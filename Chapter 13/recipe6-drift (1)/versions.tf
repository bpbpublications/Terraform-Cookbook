############################################
# versions.tf
# - Pin Terraform Core and providers
# - Configure AzureRM v4 RP registration to avoid warnings
############################################
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      # v4 line; any 4.x you tested is fine. Example:
      version = "~> 4.40"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

# AzureRM v4 provider
# Use the new RP registration knobs rather than the deprecated skip_provider_registration.
# Register only what is required by this recipe to avoid broad changes at subscription scope.
provider "azurerm" {
  features {}

  # v4 setting: do not register everything automatically
  resource_provider_registrations = "none"

  # Explicitly allow Terraform to auto-register only the RPs we actually need here.
  # This recipe uses Network and Compute (RG comes from Microsoft.Resources which is core).
  resource_providers_to_register = [
    "Microsoft.Network",
    "Microsoft.Compute"
  ]
}
