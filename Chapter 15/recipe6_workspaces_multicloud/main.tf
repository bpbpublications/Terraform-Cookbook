###############################################################
# Local Logic: Decide which cloud to target based on workspace
###############################################################

# Use the Terraform workspace name to decide which cloud to deploy into.
# Valid workspaces: "azure" and "gcp".
# If an invalid workspace is selected, default to "azure".
locals {
  target_cloud = contains(["azure", "gcp"], terraform.workspace) ? terraform.workspace : "azure"
}

###############################################################
# Random String Suffix
###############################################################

# Generate a random lowercase string to make resource names unique.
resource "random_string" "suffix" {
  length  = 6
  upper   = false   # Lowercase only
  special = false   # No special characters (Azure/GCP naming restriction)
}

###############################################################
# Azure Resources (created only if workspace == "azure")
###############################################################

# Create a Resource Group in Azure
# Uses count = 1 only if local.target_cloud == "azure"
resource "azurerm_resource_group" "rg" {
  count    = local.target_cloud == "azure" ? 1 : 0
  name     = "rg-ws-${random_string.suffix.result}" # Unique resource group name
  location = var.az_location                        # Region (default: eastus)
}

###############################################################
# GCP Resources (created only if workspace == "gcp")
###############################################################

# Create a GCP Storage Bucket
# Uses count = 1 only if local.target_cloud == "gcp"
resource "google_storage_bucket" "bucket" {
  count                       = local.target_cloud == "gcp" ? 1 : 0
  name                        = "ws-${random_string.suffix.result}-${var.gcp_project}" # Bucket name must be globally unique
  location                    = var.gcp_region      # GCP region (default: us-central1)
  uniform_bucket_level_access = true                # Enforce IAM-only access
  force_destroy               = true                # Allow bucket deletion even if it contains objects
}
