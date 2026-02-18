############################################################
# variables.tf
# Purpose: Centralize inputs for Key Vault, identity, and
#          optional private endpoint integration.
############################################################

# Region and resource group where Key Vault and identity will live
variable "region" {
  type        = string
  description = "Azure region for secrets and identity resources"
  default     = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group for Key Vault and identity"
  default     = "rg-ch17-secrets-identity"
}

# Names for Key Vault and the User Assigned Managed Identity
variable "key_vault_name" {
  type        = string
  description = "Globally unique Key Vault name (lowercase letters and digits)"
  default     = "kvch17capstone001"
}

variable "uami_name" {
  type        = string
  description = "User Assigned Managed Identity name for the app tier"
  default     = "uami-ch17-app"
}

# Optional: connect Key Vault over a private endpoint
variable "enable_private_endpoint" {
  type        = bool
  description = "If true, create a private endpoint for Key Vault"
  default     = true
}

# The VNet and Subnet to use for the Key Vault private endpoint
# Supply from Recipe 1 outputs or pass manually in tfvars
variable "vnet_id" {
  type        = string
  description = "Virtual Network ID for private endpoint DNS linking"
  default     = "" # Example: "/subscriptions/<sub>/resourceGroups/rg-ch17-core-network/providers/Microsoft.Network/virtualNetworks/vnet-ch17"
}

variable "subnet_id_for_kv_pe" {
  type        = string
  description = "Subnet ID to host the Key Vault private endpoint (use data subnet or app subnet)"
  default     = "" # Example: ".../subnets/data-subnet"
}

# Tags to enforce governance
variable "resource_tags" {
  type        = map(string)
  description = "Tags applied to all resources"
  default = {
    project     = "terraform-cookbook-capstone"
    environment = "dev"
    owner       = "platform-engineering"
  }
}
