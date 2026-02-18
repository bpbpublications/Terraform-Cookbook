############################################
# variables.tf
############################################
variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Standard tags"
  type        = map(string)
  default = {
    environment = "dev"
    owner       = "platform-team"
    cost_center = "CC100"
  }
}
