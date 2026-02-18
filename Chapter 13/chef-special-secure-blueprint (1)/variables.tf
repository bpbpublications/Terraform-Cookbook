variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "resource_prefix" {
  description = "Short prefix for resource names"
  type        = string
  default     = "c13-secure"
}

variable "admin_username" {
  description = "Admin user for Linux VM"
  type        = string
  default     = "azureuser"
}

# Never hardcode passwords in .tf files. Use Key Vault, or set via TF_VAR_ env var.
variable "ssh_public_key_path" {
  description = "Path to SSH public key used for the VM"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# Enterprise tags used in policy-as-code
variable "default_tags" {
  description = "Mandatory tags applied to all resources"
  type        = map(string)
  default = {
    environment = "dev"
    cost_center = "CC100"
    owner       = "platform-team"
  }
}
