###############################################################
# Terraform Settings
###############################################################

terraform {
  # Ensure Terraform version 1.6.0 or newer is used
  required_version = ">= 1.6.0"

  # Declare required providers and their version constraints
  required_providers {
    azurerm = { 
      source  = "hashicorp/azurerm"  # Azure Resource Manager provider
      version = "~> 3.110"           # Use v3.110.x, stay within patch releases
    }
    google = { 
      source  = "hashicorp/google"   # Google Cloud provider
      version = "~> 6.0"             # Use v6.x, stay within patch releases
    }
  }
}

###############################################################
# Azure Provider Configuration
###############################################################

provider "azurerm" {
  features {}
  # "features" block is required, even if empty.
  # Authentication is typically handled via:
  # - Azure CLI (az login)
  # - Environment variables (ARM_CLIENT_ID, ARM_CLIENT_SECRET, etc.)
  # - Managed Identity if running inside Azure
}

###############################################################
# Google Cloud Provider Configuration
###############################################################

provider "google" {
  project = var.gcp_project  # GCP project ID, passed via variable
  region  = var.gcp_region   # Default region for resources

  # Authentication is typically handled via:
  # - GOOGLE_APPLICATION_CREDENTIALS environment variable
  # - gcloud CLI with "gcloud auth application-default login"
  # - Workload Identity Federation (enterprise setup)
}
