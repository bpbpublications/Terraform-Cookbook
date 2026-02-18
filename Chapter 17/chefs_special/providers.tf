#########################################################
# Terraform Settings
#########################################################
terraform {
  # Required providers define the plugins Terraform uses
  # Each provider has a source (namespace/repo) and a version constraint
  required_providers {
    
    # Azure Resource Manager provider
    # Used to create and manage Azure resources
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    # Random provider
    # Generates random values (strings, numbers, etc.)
    # Useful for unique naming and test data
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }

    # Time provider
    # Manages time-based resources such as delays or timestamps
    # Often used in testing or when simulating schedules
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
  }

  # (Optional) You could also enforce a Terraform CLI version:
  # required_version = ">= 1.5.0"
}

#########################################################
# AzureRM Provider Configuration
#########################################################
# The provider block configures access to Azure
# Terraform will use your Azure CLI or environment credentials
# to authenticate unless otherwise specified.
provider "azurerm" {
  features {} 
  # The 'features' block is required but can be left empty
  # You can enable advanced features like key vault soft delete here if needed.
}
