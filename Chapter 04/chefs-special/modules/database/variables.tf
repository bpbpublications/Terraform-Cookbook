variable "db_name" {
  type = string
}
variable "location" {
  type = string
}
variable "rg_name" {
  type = string
}
variable "vnet_id" {
  description = "ID of the VNet for private DNS linkage"
  type        = string
}
variable "admin_username" {
  type = string
}
variable "admin_password" {
  type = string
}
variable "sku_name" {
  type        = string
  description = "SKU Name for PostgreSQL Flexible Server (tier prefix + name, e.g. B_Standard_B1ms)"
  default     = "B_Standard_B1ms"  # Burstable tier prefix B_ + Standard_B1ms
}
variable "storage_mb" {
  type    = number
  default = 32768
}
variable "db_subnet_id" {
  type = string
}