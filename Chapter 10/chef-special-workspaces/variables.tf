variable "env" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "instance_count" {
  description = "How many app instances to deploy"
  type        = number
}

variable "sku" {
  description = "App Service plan SKU"
  type        = string
}

variable "enable_advanced_monitoring" {
  description = "Create extra monitoring in prod only"
  type        = bool
  default     = false
}
