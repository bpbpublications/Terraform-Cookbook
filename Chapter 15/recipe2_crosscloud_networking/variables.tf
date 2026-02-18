###############################################################
# General
###############################################################

# Pre-shared key for the IPsec VPN tunnel
# This must be the same on both Azure and GCP sides for tunnel establishment.
variable "psk" {
  description = "Pre-shared key for the IPsec tunnel"
  type        = string
  sensitive   = true   # Marked sensitive so it is not displayed in CLI output
}

###############################################################
# Azure Configuration
###############################################################

# Azure region where all resources will be deployed
variable "az_location" {
  type    = string
  default = "eastus"
}

# CIDR block for the Azure Virtual Network (VNet)
variable "az_vnet_cidr" {
  type    = string
  default = "10.60.0.0/16"
}

# CIDR block for the primary application subnet
variable "az_subnet_cidr" {
  type    = string
  default = "10.60.1.0/24"
}

# Special subnet for the VPN Gateway
# Must be named **GatewaySubnet** and meet minimum size requirements (/27 or larger).
# This is a strict Azure requirement for creating VPN gateways.
variable "az_gwsubnet_cidr" {
  type    = string
  default = "10.60.255.0/27"
}

###############################################################
# Google Cloud Configuration
###############################################################

# Google Cloud project ID
# Required since GCP resources must belong to a project
variable "gcp_project" {
  type        = string
  description = "GCP project ID"
}

# GCP region for resource deployment
variable "gcp_region" {
  type    = string
  default = "us-central1"
}

# CIDR block for the Google VPC network
variable "gcp_vpc_cidr" {
  type    = string
  default = "10.70.0.0/16"
}

# CIDR block for the Google VPC subnet
variable "gcp_subnet_cidr" {
  type    = string
  default = "10.70.1.0/24"
}
