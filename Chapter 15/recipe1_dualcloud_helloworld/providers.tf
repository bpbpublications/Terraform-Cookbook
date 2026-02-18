terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

# Azure authenticates via Azure CLI or environment variables.
provider "azurerm" {
  features {}
}

# Google Cloud authenticates via Application Default Credentials or a JSON key file.
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}
