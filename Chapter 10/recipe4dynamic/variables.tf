variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "UK South"
}

# Each object defines a rule name and destination port.
variable "rules" {
  description = "List of inbound NSG rules to create"
  type = list(object({
    name = string
    port = number
  }))
  default = []
}