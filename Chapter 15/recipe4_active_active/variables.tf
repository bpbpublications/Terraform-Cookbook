###############################################################
# Input Variables for Multi-Cloud Active-Active Deployment
# Defines regions, project IDs, and container images for Azure and GCP
###############################################################

# Azure region where resources will be deployed
# Default is set to "eastus" but can be overridden at runtime
variable "az_location" {
  type    = string
  default = "eastus"
}

# Google Cloud project ID
# Must be provided because GCP requires a project to associate resources
variable "gcp_project" {
  type = string
}

# Google Cloud region where resources will be deployed
# Default is "us-central1" (a common GCP region)
variable "gcp_region" {
  type    = string
  default = "us-central1"
}

###############################################################
# Container Images to Deploy
###############################################################

# Container image for Azure App Service (from Docker Hub or ACR)
# Default uses the latest Nginx image from Docker Hub
variable "azure_container_image" {
  type    = string
  default = "nginx:latest"
}

# Container image for GCP Cloud Run
# Default uses a sample "hello" container hosted in Google Artifact Registry
variable "gcp_container_image" {
  type    = string
  default = "us-docker.pkg.dev/cloudrun/container/hello"
}
