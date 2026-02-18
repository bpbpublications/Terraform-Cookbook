variable "region" {
  description = "Azure region to deploy resources in"
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
  description = "Address space for the VNet"
  type        = list(string)
}

variable "subnet_map" {
  description = "Map of subnets with CIDR values"
  type        = map(string)
}
