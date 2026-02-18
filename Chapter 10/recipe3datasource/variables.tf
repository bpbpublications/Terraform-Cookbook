variable "location" {
  description = "Azure region for the VM"
  type        = string
  default     = "UK South"
}

variable "existing_rg" {
  description = "Resource group that contains the existing VNet"
  type        = string
}

variable "existing_vnet_name" {
  description = "Name of the existing VNet"
  type        = string
}

variable "existing_subnet_name" {
  description = "Name of the subnet inside the VNet"
  type        = string
}