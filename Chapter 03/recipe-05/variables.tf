variable "region" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}

variable "vm_size" {
  description = "Azure VM SKU"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_public_key" {
  description = "SSH public key for azureuser"
  type        = string
}

variable "admin_password" {
  description = "Local admin password for the VM"
  type        = string
  sensitive   = true   # Masks value in CLI output
}