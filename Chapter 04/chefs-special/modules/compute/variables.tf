variable "rg_name" {
  type = string
}
variable "location" {
  type = string
}
variable "app_subnet_id" {
  type = string
}
variable "admin_public_key" {
  type = string
}
variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}
variable "vm_count" {
  type    = number
  default = 2
}