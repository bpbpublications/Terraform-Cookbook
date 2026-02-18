############################################################
# variables.tf
# Purpose: Centralize inputs for the application tier.
############################################################

# Azure region and resource group for the app tier
variable "region" {
  type        = string
  description = "Azure region for application tier resources"
  default     = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name for the application tier"
  default     = "rg-ch17-app-tier"
}

# VM size for the app tier
variable "vm_sku" {
  type        = string
  description = "Azure VM size for the scale set"
  # Choose a broadly available size; override in dev.tfvars if desired
  default = "Standard_DS1_v2"
}

# Zones to use. Leave empty to let Azure place VMs without zone pinning.
variable "availability_zones" {
  type        = list(string)
  description = "Availability zones for the VMSS; set [] to disable zone pinning"
  default     = []
}

# Subnet and VNet inputs from Recipe 1
variable "app_subnet_id" {
  type        = string
  description = "Subnet ID for the application tier (use app subnet from Recipe 1)"
}

# Private frontend IP for the internal Load Balancer
variable "ilb_private_ip" {
  type        = string
  description = "Static private IP for the internal Load Balancer (must be inside app subnet CIDR)"
  default     = "10.0.2.10"
}

# Scale and availability
variable "instance_count" {
  type        = number
  description = "Number of VMSS instances"
  default     = 2
}

# SSH admin settings for Linux VMs
variable "admin_username" {
  type        = string
  description = "Admin username for Linux VMs"
  default     = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for admin user"
  default     = "" # Paste your public key here or provide via tfvars
}

# App port inside the VMs and on the internal Load Balancer
variable "app_port" {
  type        = number
  description = "Port the sample app listens on"
  default     = 8080
}

# User Assigned Managed Identity resource ID created in Recipe 2
variable "uami_id" {
  type        = string
  description = "Resource ID of the User Assigned Managed Identity from Recipe 2"
}

# Optional: Key Vault URI if the app needs to reference it at deploy time
variable "key_vault_uri" {
  type        = string
  description = "Key Vault URI for the application (optional)"
  default     = ""
}

# Tags
variable "resource_tags" {
  type        = map(string)
  description = "Tags applied to all resources"
  default = {
    project     = "terraform-cookbook-capstone"
    environment = "dev"
    owner       = "platform-engineering"
  }
}

# Optional: resolve UAMI by name if uami_id is not provided or is mis-cased
variable "uami_rg_name" {
  type        = string
  description = "Resource Group that contains the User Assigned Managed Identity"
  default     = "rg-ch17-secrets-identity"
}

variable "uami_name" {
  type        = string
  description = "User Assigned Managed Identity name"
  default     = "uami-ch17-app"
}

