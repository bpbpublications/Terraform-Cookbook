variable "region" {
  description = "Azure region"
  type        = string
}

variable "rg_name" {
  description = "Resource Group name"
  type        = string
}

variable "subnet_ids" {
  description = "Map of subnet IDs per tier"
  type        = map(string)
}

variable "subnet_cidrs" {
  description = "CIDR values for each subnet"
  type        = map(string)
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
}
