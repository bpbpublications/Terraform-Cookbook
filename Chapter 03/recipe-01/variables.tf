variable "region" {
  description = "Azure region for all resources"
  type        = string
  default     = "uksouth"
}

variable "vm_size" {
  description = "Azure VM SKU"
  type        = string
  default     = "Standard_B1s"
}

# Paste your **public** SSH key (contents of id_rsa.pub)
variable "admin_public_key" {
  description = "SSH public key for azureuser"
  type        = string
}