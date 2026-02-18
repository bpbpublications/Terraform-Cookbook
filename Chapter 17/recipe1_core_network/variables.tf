#############################################
# variables.tf
# Purpose: Centralize all tunable inputs for
#          region, naming, CIDRs, tags, and
#          baseline port rules for NSGs.
#############################################

# Azure region to deploy resources in
variable "region" {
  type        = string
  description = "Azure region for all resources"
  default     = "eastus"
}

# Resource Group name to group all network resources
variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group for core network"
  default     = "rg-ch17-core-network"
}

# Virtual Network name
variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network"
  default     = "vnet-ch17"
}

# Address space for the VNet
variable "address_space" {
  type        = list(string)
  description = "CIDR blocks for the Virtual Network"
  default     = ["10.0.0.0/16"]
}

# Subnet CIDRs for tiered architecture
variable "subnet_cidrs" {
  description = "CIDR definitions for web, app, and data subnets"
  type = object({
    web  = string
    app  = string
    data = string
  })
  default = {
    web  = "10.0.1.0/24"
    app  = "10.0.2.0/24"
    data = "10.0.3.0/24"
  }
}

# Baseline ports that the web tier is expected to serve
variable "web_allowed_inbound_ports" {
  type        = list(number)
  description = "Inbound ports open to Internet on web subnet NSG"
  default     = [80, 443]
}

# Application tier service port from web tier
variable "app_inbound_port_from_web" {
  type        = number
  description = "Inbound port on app subnet NSG allowed from web subnet"
  default     = 8080
}

# Database port from app tier to data tier (example uses SQL Server)
variable "db_inbound_port_from_app" {
  type        = number
  description = "Inbound port on data subnet NSG allowed from app subnet"
  default     = 1433
}

# Standardized tags to enforce governance and cost allocation
variable "resource_tags" {
  type        = map(string)
  description = "Tags applied to all resources"
  default = {
    project     = "terraform-cookbook-capstone"
    environment = "dev"
    owner       = "platform-engineering"
  }
}
