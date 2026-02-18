variable "location" {
  description = "Location for resources"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "vm_admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
}
