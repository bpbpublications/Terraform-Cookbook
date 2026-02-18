###############################################################
# Azure Variables
###############################################################

# Azure region where resources will be deployed.
# Default is set to "eastus", but you can override it when running Terraform.
variable "az_location" {
  type    = string
  default = "eastus"
}

###############################################################
# Google Cloud Variables
###############################################################

# Google Cloud project ID
# This must be explicitly provided because GCP resources must belong to a project.
variable "gcp_project" {
  type        = string
  description = "Google Cloud project ID"
}

# Google Cloud region for resource deployment
# Default is "us-central1", one of the most common GCP regions.
variable "gcp_region" {
  type    = string
  default = "us-central1"
}

###############################################################
# Security Variable (Azure SAS Token)
###############################################################

# SAS token for accessing the Azure Blob container.
# In this recipe, it is only used by Google Storage Transfer Service to read from Azure.
# ⚠️ Important: In production, do NOT hardcode SAS tokens here.
# Instead, store them in Secret Manager or use federated identity per Google’s security best practices.
variable "azure_container_sas_token" {
  type        = string
  description = "Container SAS token for the Azure Blob source, beginning with '?sv='"
  sensitive   = true # Marked sensitive to prevent accidental logging in Terraform output
}
