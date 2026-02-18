variable "location" {
  description = "Azure region"
  type        = string
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
}

variable "storage_name" {
  description = "Prefix for the Storage Account name"
  type        = string
}

variable "account_tier" {
  description = "Storage account tier"
  type        = string
}

variable "replication_type" {
  description = "Replication type"
  type        = string
}