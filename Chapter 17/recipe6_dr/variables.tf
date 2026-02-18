# Naming and tags
variable "project" {
  type    = string
  default = "terraform-cookbook-capstone"
}

variable "owner" {
  type    = string
  default = "platform-engineering"
}

variable "environment" {
  type    = string
  default = "dev"
}

# Regions and resource groups
variable "primary_location" {
  type    = string
  default = "eastus2"
}

variable "dr_location" {
  type    = string
  default = "centralus"
}

variable "dr_rg_name" {
  type    = string
  default = "rg-ch17-dr"
}

variable "primary_rg_name" {
  type    = string
  default = "rg-ch17-managed-db"
}

# Networking objects (reused from earlier recipes)
variable "data_subnet_id" {
  type = string
}

variable "sql_private_dns_zone_id" {
  type = string
}

# Primary SQL objects created in Recipe 4
variable "primary_sql_server_name" {
  type = string
}

variable "primary_database_name" {
  type    = string
  default = "appdb"
}

# Key Vault from Recipe 2
variable "key_vault_id" {
  type = string
}

variable "key_vault_name" {
  type        = string
  description = "Name of the existing Azure Key Vault that stores DR-related secrets."
}

variable "key_vault_rg_name" {
  type        = string
  description = "Resource group name that contains the Key Vault."
}


# Failover Group settings
variable "failover_group_name" {
  type    = string
  default = "fog-ch17-app"
}

variable "rw_mode" {
  description = "Automatic or Manual"
  type        = string
  default     = "Automatic"
}

variable "rw_grace_minutes" {
  type    = number
  default = 60
}

variable "readonly_failover_enabled" {
  type    = bool
  default = true
}

variable "sql_admin_password_version" {
  description = "Bump this integer to rotate the SQL admin password when using the write-only field."
  type        = number
  default     = 1
}

# variables.tf
variable "core_vnet_rg_name" {
  type        = string
  description = "Resource group containing the core VNet"
  default     = "rg-ch17-core-network"
}

variable "core_vnet_name" {
  type        = string
  description = "Core VNet name"
  default     = "vnet-ch17"
}

variable "data_subnet_name" {
  type        = string
  description = "Data tier subnet name"
  default     = "data-subnet"
}

