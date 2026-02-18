variable "region" {
  description = "Azure region for the VM"
  type        = string
  default     = "uksouth"
}

variable "vm_size" {
  description = "Azure VM size/SKU for Windows VM"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_password" {
  description = "Admin password for the Windows VM"
  type        = string
  sensitive   = true
}
