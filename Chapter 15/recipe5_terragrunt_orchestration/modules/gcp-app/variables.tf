###############################################################
# Google Cloud App Deployment Variables
###############################################################

# GCP region where resources will be deployed
# Default uses "us-central1", one of the most common GCP regions
variable "gcp_region" {
  type    = string
  default = "us-central1"
}

# Application name prefix (used in resource names like Cloud Run service)
variable "app_name" {
  type    = string
  default = "tg-app-gcp"
}

# Container image to deploy into Google Cloud Run
# Default uses a sample "hello" container from Artifact Registry
variable "gcp_container_image" {
  type    = string
  default = "us-docker.pkg.dev/cloudrun/container/hello"
}
