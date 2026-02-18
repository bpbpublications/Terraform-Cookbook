###############################################################
# Azure App Deployment Variables
###############################################################

# Azure region where resources will be deployed
variable "az_location" {
  type    = string
  default = "eastus"
}

# Application name prefix (used for resources like App Service)
variable "app_name" {
  type    = string
  default = "tg-app-az"
}

# Container image to deploy into Azure App Service
# Default uses the latest Nginx image from Docker Hub
variable "azure_container_image" {
  type    = string
  default = "nginx:latest"
}
