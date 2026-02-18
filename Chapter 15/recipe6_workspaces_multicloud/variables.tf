###############################################################
# Azure Configuration
###############################################################

# Azure region where resources will be deployed
# Default is "eastus", but can be overridden
variable "az_location" {
  type    = string
  default = "eastus"
}

###############################################################
# Google Cloud Configuration
###############################################################

# Google Cloud project ID
# Required, since GCP resources must always belong to a project
variable "gcp_project" {
  type        = string
  description = "GCP project ID"
}

# Google Cloud region where resources will be deployed
# Default is "us-central1", one of GCP's main regions
variable "gcp_region" {
  type    = string
  default = "us-central1"
}
