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

variable "disk_size_gb" {
  description = "Data disk size in GB"
  type        = number
  default     = 32
}

variable "admin_public_key" {
  description = "SSH public key for azureuser"
  type        = string
}