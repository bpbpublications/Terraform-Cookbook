variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "eastus"
}

variable "env_prefix" {
  description = "Prefix for resource names (blue/green)"
  type        = string
  default     = "blue" # Initial active environment
}

variable "app_version" {
  description = "App version tag (e.g., v1, v2)"
  type        = string
  default     = "v1"
}

variable "vm_count" {
  description = "Number of VM instances per environment"
  type        = number
  default     = 2
}

variable "admin_username" {
  description = "VM admin username"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}