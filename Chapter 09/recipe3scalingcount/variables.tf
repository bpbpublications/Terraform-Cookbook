# File: variables.tf

variable "resource_group_name" {
  description = "Name of the resource group for App Services"
  type        = string
  default     = "rg-chapter9-count"
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "uksouth"
}

variable "app_service_plan_sku" {
  description = "SKU tier for the App Service Plan"
  type        = string
  default     = "P1v2"
}

variable "web_count" {
  description = "Number of App Service instances to create"
  type        = number
  default     = 2
}

variable "app_service_prefix" {
  description = "Prefix for App Service names"
  type        = string
  default     = "webapp"
}
