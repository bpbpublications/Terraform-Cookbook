variable "region" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}

variable "vm_id" {
  description = "Azure Resource ID of the virtual machine to be protected by backup"
  type        = string
}
