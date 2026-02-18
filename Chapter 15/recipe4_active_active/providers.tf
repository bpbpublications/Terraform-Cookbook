###############################################################
# Terraform Configuration and Provider Requirements
###############################################################

terraform {
  # Ensure that users run Terraform v1.5.0 or later
  required_version = ">= 1.5.0"

  # Declare required providers and their versions
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm" # Azure Resource Manager provider
      version = ">= 4.0.0"          # Require v4.x or later
    }
    google = {
      source  = "hashicorp/google" # Google Cloud provider
      version = ">= 7.0.0"         # Require v7.x or later
    }
    random = {
      source  = "hashicorp/random" # Random provider (for unique names, suffixes, etc.)
      version = ">= 3.5.0"         # Require v3.5.0 or later
    }
  }
}

###############################################################
# Azure Provider Configuration
###############################################################

provider "azurerm" {
  features {}
  # "features" block is required even if empty.
  # Authentication is handled via environment variables,
  # Azure CLI (`az login`), or Managed Identity if running in Azure.
}

###############################################################
# Google Cloud Provider Configuration
###############################################################

provider "google" {
  project = var.gcp_project # GCP project ID (passed in via variable)
  region  = var.gcp_region  # Default region for GCP resources

  # Authentication is typically handled with:
  # - GOOGLE_APPLICATION_CREDENTIALS environment variable
  # - gcloud CLI (with `gcloud auth application-default login`)
  # - Workload Identity Federation (for enterprise setups)
}
