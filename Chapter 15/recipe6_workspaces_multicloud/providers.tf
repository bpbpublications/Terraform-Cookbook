###############################################################
# Terraform Settings
###############################################################

terraform {
  # Enforce Terraform CLI version 1.6.0 or newer
  required_version = ">= 1.6.0"

  # Define required providers and their version constraints
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm" # Azure Resource Manager provider
      version = ">= 4.0.0"          # Require v4.0.0 or newer
    }
    google = {
      source  = "hashicorp/google"  # Google Cloud provider
      version = ">= 7.0.0"          # Require v7.0.0 or newer
    }
    random = {
      source  = "hashicorp/random"  # Random provider (useful for unique suffixes, passwords, etc.)
      version = ">= 3.5.0"          # Require v3.5.0 or newer
    }
  }
}

###############################################################
# Azure Provider Configuration
###############################################################

provider "azurerm" {
  features {}
  # The "features" block is mandatory, even if left empty.
  # Authentication can be handled via:
  # - Azure CLI (az login)
  # - Environment variables (ARM_CLIENT_ID, ARM_CLIENT_SECRET, etc.)
  # - Managed Identity if running inside Azure
}

###############################################################
# Google Cloud Provider Configuration
###############################################################

provider "google" {
  project = var.gcp_project # GCP Project ID (passed via variables)
  region  = var.gcp_region  # Default region for resources

  # Authentication options:
  # - GOOGLE_APPLICATION_CREDENTIALS env variable pointing to a JSON key
  # - gcloud CLI with "gcloud auth application-default login"
  # - Workload Identity Federation (for enterprise setups)
}
