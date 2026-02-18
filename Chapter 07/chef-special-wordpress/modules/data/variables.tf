variable "region" {
  type        = string
  default     = "uksouth"
  description = "Azure region"
}

variable "rg_name" {
  type        = string
  description = "Resource group name"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Password for MySQL admin user"
}