variable "region" {
  description = "Azure region"
  type        = string
}

variable "rg_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "CIDR block for the virtual network"
  type        = list(string)
}

variable "subnet_map" {
  description = "Map of subnet names and CIDRs"
  type        = map(string)
}
