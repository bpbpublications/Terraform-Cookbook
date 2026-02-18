# main.tf

#############################################
# AzureRM provider configuration
#############################################
provider "azurerm" {
  features {}
  # Leave authentication to az CLI login or environment variables.
  # For this recipe we do not create Azure resources, so this can remain minimal.
}

#############################################
# Small demo resource from "random" provider
# - Confirms provider resolution and version pinning work
# - Avoids any cloud charges
#############################################
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  lower   = true
  special = false

  # Use ONLY 'numeric'. Do not set 'number'.
  # This avoids the deprecation warning you observed.
  numeric = true
}
