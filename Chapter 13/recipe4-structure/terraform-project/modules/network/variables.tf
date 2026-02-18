# Region to deploy networking resources
variable "location" {
  type        = string
  description = "Azure region"
}

# Resource group name into which the network is created
variable "resource_group_name" {
  type        = string
  description = "Existing or newly created RG name"
}

# VNet and subnet shapes
variable "vnet_cidr" {
  type        = string
  description = "CIDR for the virtual network"
}

variable "subnet_cidrs" {
  type        = map(string)
  description = "Map of subnet name to CIDR"
}

# Standard tags to apply to every resource
variable "tags" {
  type        = map(string)
  description = "Common tags"
  default     = {}
}
