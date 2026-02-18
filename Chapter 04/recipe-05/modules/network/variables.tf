variable "env" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

variable "address_space" {
  description = "CIDR block for this VNet"
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