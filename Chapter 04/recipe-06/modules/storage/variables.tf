variable "storage_name" {
  description = "Prefix for the Storage Account name (3–18 chars)"
  type        = string
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "account_tier" {
  description = "Storage account tier (Standard/Premium)"
  type        = string
}

variable "replication_type" {
  description = "Replication type (LRS/GRS/etc)"
  type        = string
}