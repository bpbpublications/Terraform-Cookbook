# GCP variables
variable "gcp_project" {
  type        = string
  description = "GCP project ID"
}
variable "gcp_region" {
  type        = string
  description = "GCP region"
  default     = "us-central1"
}

# Azure variables
variable "az_location" {
  type        = string
  description = "Azure region"
  default     = "eastus"
}
variable "admin_username" {
  type    = string
  default = "cookbook"
}
# Path to your SSH public key for both VMs (Windows path shown)
variable "ssh_public_key_path" {
  type    = string
  default = "C:/Users/<you>/.ssh/id_rsa.pub"
}
