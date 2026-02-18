# Azure location where resources will be deployed
# Default is set to "eastus" but can be overridden
variable "az_location" {
  type    = string
  default = "eastus"
}

# Google Cloud project ID
# This is required because Terraform needs to know which GCP project
# to associate resources with (no default provided, must be passed in)
variable "gcp_project" {
  type        = string
  description = "GCP project ID"
}

# Google Cloud region where resources will be deployed
# Default is set to "us-central1" but can be changed when needed
variable "gcp_region" {
  type    = string
  default = "us-central1"
}

# Path to the SSH public key used for VM access
# Default path points to a typical local key file, but can be customized
variable "ssh_public_key_path" {
  type        = string
  description = "Path to your SSH public key"
  default     = "C:/Users/huzef/.ssh/id_rsa.pub"
}
