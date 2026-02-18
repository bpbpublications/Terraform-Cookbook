# Input surface for dev environment composition

variable "location" {
  type        = string
  description = "Azure region"
  default     = "eastus"
}

variable "rg_name" {
  type        = string
  description = "Resource group to create or re-use"
  default     = "rg-cookbook-dev"
}

variable "vnet_cidr" {
  type        = string
  description = "CIDR for VNet"
  default     = "10.10.0.0/16"
}

variable "subnet_cidrs" {
  type        = map(string)
  description = "Subnets for the VNet"
  default = {
    "subnet-app" = "10.10.1.0/24"
    "subnet-db"  = "10.10.2.0/24"
  }
}

variable "vm_size" {
  type        = string
  description = "VM size used in dev"
  default     = "Standard_B1ms"
}
