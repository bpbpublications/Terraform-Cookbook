# versions.tf
terraform {
  # Keep your installed Terraform 1.11.x. Adjust upper bound as your policy requires.
  required_version = ">= 1.11.0, < 2.0.0"

  required_providers {
    # AzureRM provider (use a stable 4.x line in enterprise settings)
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    # Random provider for demo purposes
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
