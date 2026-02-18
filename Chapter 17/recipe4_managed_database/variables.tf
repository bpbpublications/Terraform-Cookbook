#################################################################
# variables.tf
# Purpose: Centralize inputs for the SQL service and networking.
#################################################################

# Region and RG for database resources
variable "region" {
  type        = string
  description = "Azure region for the managed database"
  default     = "uksouth"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for the managed database"
  default     = "rg-ch17-managed-db"
}

# SQL logical server and database names
# Server name must be globally unique (lowercase letters and digits only)
variable "sql_server_name" {
  type        = string
  description = "Globally unique SQL server name (lowercase letters and digits)"
  default     = "sqlsvrch17cap001"
}

variable "sql_database_name" {
  type        = string
  description = "SQL Database name"
  default     = "appdb"
}

# Networking for private endpoint
variable "vnet_id" {
  type        = string
  description = "VNet ID for Private DNS zone linking"
  default     = "" # Example: "/subscriptions/<sub>/resourceGroups/rg-ch17-core-network/providers/Microsoft.Network/virtualNetworks/vnet-ch17"
}

variable "subnet_id_for_sql_pe" {
  type        = string
  description = "Subnet ID to host the SQL private endpoint (use data subnet)"
  default     = "" # Example: ".../subnets/data-subnet"
}

# Control whether to create and enforce a private endpoint
variable "enable_private_endpoint" {
  type        = bool
  description = "If true, create a private endpoint and disable public access"
  default     = true
}

# Key Vault integration for secrets (from Recipe 2)
variable "key_vault_id" {
  type        = string
  description = "Key Vault resource ID to store admin credentials and connection string"
  default     = "" # Example: "/subscriptions/<sub>/resourceGroups/rg-ch17-secrets-identity/providers/Microsoft.KeyVault/vaults/kvch17capstone001"
}

variable "key_vault_uri" {
  type        = string
  description = "Key Vault URI used by applications to read secrets"
  default     = "" # Example: "https://kvch17capstone001.vault.azure.net/"
}

# Tags for governance
variable "resource_tags" {
  type        = map(string)
  description = "Tags applied to all resources"
  default = {
    project     = "terraform-cookbook-capstone"
    environment = "dev"
    owner       = "platform-engineering"
  }
}

# Region for Azure SQL (can differ from VNet/PE region)
variable "db_region" {
  type        = string
  description = "Azure region for the SQL logical server and database"
  default     = "eastus2" # choose a region allowed in your subscription
}

# Database SKU - keep Business Critical by default
variable "db_sku_name" {
  type        = string
  description = "Azure SQL Database SKU name"
  # Examples: BC_Gen5_2 (Business Critical), HS_Gen5_2 (Hyperscale), GP_Gen5_2 (General Purpose)
  default = "BC_Gen5_2"
}

# Toggle zone redundancy
variable "db_zone_redundant" {
  type        = bool
  description = "Enable zone redundancy for the database if supported in the selected region and subscription"
  default     = false
}
