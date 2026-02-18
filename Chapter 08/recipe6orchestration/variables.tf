variable "vm_admin_username" {
  type = string
  default = "azureuser"
}
variable "vm_admin_password" {
  type        = string
  description = "Admin password for VM (use a complex password for actual use)"
  default     = "P@ssword1234!"  # Only for demo; consider using sensitive/TF_VAR or SSH keys in real use.
}
variable "location" {
  type    = string
  default = "eastus"
}
