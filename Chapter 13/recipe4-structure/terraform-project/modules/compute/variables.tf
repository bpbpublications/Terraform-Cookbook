variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "subnet_id" {
  type        = string
  description = "Subnet where the VM will be placed"
}

variable "vm_name" {
  type        = string
  description = "Virtual machine name"
}

variable "vm_size" {
  type        = string
  description = "VM size, for example Standard_B2s"
  default     = "Standard_B2s"
}

variable "admin_username" {
  type        = string
  description = "Admin username"
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key file"
  default     = "~/.ssh/id_rsa.pub"
}

variable "tags" {
  type        = map(string)
  description = "Standard tags"
  default     = {}
}
