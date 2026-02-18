###############################################################
# Terraform Settings
###############################################################

terraform {
  # Require Terraform CLI version 1.6.0 or newer
  required_version = ">= 1.6.0"

  # Declare providers and pin compatible versions
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm" # Azure Resource Manager provider
      version = ">= 4.0.0"          # Use v4.0.0 or later
    }
    google = {
      source  = "hashicorp/google" # Google Cloud provider
      version = ">= 7.0.0"         # Use v7.0.0 or later
    }
    random = {
      source  = "hashicorp/random" # Utility provider for suffixes, strings, etc.
      version = ">= 3.5.0"         # Use v3.5.0 or later
    }
  }
}

###############################################################
# Azure Provider Configuration
###############################################################

provider "azurerm" {
  features {}
  # The 'features' block is required (even if empty).
  # Authentication options (pick one):
  #  - Azure CLI:        az login
  #  - Env vars:         ARM_CLIENT_ID / ARM_CLIENT_SECRET / ARM_TENANT_ID / ARM_SUBSCRIPTION_ID
  #  - Managed Identity: when running inside Azure
  # Tip: set subscription via AZURE_SUBSCRIPTION_ID or 'az account set --subscription ...'
}

###############################################################
# Google Cloud Provider Configuration
###############################################################

provider "google" {
  project = var.gcp_project # GCP project ID (must exist)
  region  = var.gcp_region  # Default region for resources

  # Authentication options (pick one):
  #  - ADC JSON key:  GOOGLE_APPLICATION_CREDENTIALS=/path/key.json
  #  - gcloud CLI:    gcloud auth application-default login
  #  - Workforce/Workload Identity Federation for enterprise setups
}
