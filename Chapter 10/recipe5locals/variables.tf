variable "env" {
  description = "Deployment environment (dev, test, prod)"
  type        = string
}

variable "app" {
  description = "Application identifier"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "UK South"
}