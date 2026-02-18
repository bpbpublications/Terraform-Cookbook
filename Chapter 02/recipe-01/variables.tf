variable "rg_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "rg-chapter2-demo"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}