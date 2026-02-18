# Specify required providers and their versions
terraform {
  required_providers {
    azurerm = { 
      source  = "hashicorp/azurerm"  # AzureRM provider for Azure resources
      version = ">= 3.0"             # Minimum version required
    }
    google = { 
      source  = "hashicorp/google"   # Google provider for GCP resources
      version = ">= 5.0"             # Minimum version required
    }
  }
}

# Input variables
variable "cloud" { 
  type = string 
  # Determines which cloud to deploy to: "azure" or "gcp"
}

variable "name" { 
  type = string 
  # Resource name prefix (used across modules)
}

variable "ssh_public_key" { 
  type = string 
  # SSH public key for VM access
}

variable "az_location" {
  type    = string
  default = null
  # Azure location (only required if deploying to Azure)
}

variable "gcp_region" {
  type    = string
  default = null
  # GCP region (only required if deploying to GCP)
}

# Azure module - only created if cloud == "azure"
module "azure" {
  count  = var.cloud == "azure" ? 1 : 0  # Deploy module only when targeting Azure
  source = "./azure"                     # Path to Azure-specific module

  # Pass required variables to the Azure module
  name           = var.name
  az_location    = var.az_location
  ssh_public_key = var.ssh_public_key

  # Explicit provider assignment
  providers = { azurerm = azurerm }
}

# GCP module - only created if cloud == "gcp"
module "gcp" {
  count  = var.cloud == "gcp" ? 1 : 0    # Deploy module only when targeting GCP
  source = "./gcp"                       # Path to GCP-specific module

  # Pass required variables to the GCP module
  name           = var.name
  gcp_region     = var.gcp_region
  ssh_public_key = var.ssh_public_key

  # Explicit provider assignment
  providers = { google = google }
}

# Output the public endpoint depending on chosen cloud
output "public_endpoint" {
  value = var.cloud == "azure" 
    ? module.azure[0].public_ip  # Azure: return public IP from Azure module
    : module.gcp[0].nat_ip       # GCP: return NAT IP from GCP module
}
