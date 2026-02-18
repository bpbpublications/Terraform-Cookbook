variable "region" {
  type        = string
  description = "Azure region"
  default     = "uksouth"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key file"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Admin password for MySQL"
}
