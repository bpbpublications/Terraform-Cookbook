variable "region" {
  description = "Azure region for all resources"
  type        = string
  default     = "uksouth"
}

variable "vm_size" {
  description = "Azure VM SKU size"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_public_key" {
  description = "SSH public key for VM login"
  type        = string
  sensitive   = true
}
