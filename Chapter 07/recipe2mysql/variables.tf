variable "region" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}

variable "mysql_password" {
  description = "The password for the MySQL administrator user"
  type        = string
  sensitive   = true
}