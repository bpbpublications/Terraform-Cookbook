variable "vnet_name" {
  description = "Name of the VNet"
  type        = string
}
variable "address_space" {
  description = "List of CIDR blocks"
  type        = list(string)
}
variable "location" {
  description = "Azure region"
  type        = string
}
variable "rg_name" {
  description = "Resource group name"
  type        = string
}