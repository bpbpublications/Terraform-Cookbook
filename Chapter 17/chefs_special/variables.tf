# Project naming and environment 
variable "project" {
  type    = string
  default = "terraform-cookbook-capstone"
}

variable "environment" {
  type    = string
  default = "dev"
}

# Regions
variable "location_primary" {
  type    = string
  default = "uksouth" # Choose a region with your required SKUs
}

variable "location_secondary" {
  type    = string
  default = "centralus" # Used later if you extend DR
}

# Networking
variable "vnet_address_space" {
  type    = list(string)
  default = ["10.20.0.0/16"]
}

variable "subnet_web_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "subnet_app_cidr" {
  type    = string
  default = "10.20.2.0/24"
}

variable "subnet_data_cidr" {
  type    = string
  default = "10.20.3.0/24"
}

# Compute
variable "vmss_sku" {
  type    = string
  default = "Standard_B4ms" # Pick a currently available SKU in your region
}

variable "vmss_instances" {
  type    = number
  default = 2
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_ssh_public_key" {
  type = string
  # paste your SSH public key
}

# Database
variable "sql_admin_login" {
  type    = string
  default = "sqladmin"
}

variable "sql_sku_name" {
  type    = string
  default = "GP_Gen5_2" # General Purpose, Gen5
}

variable "sql_zone_redundant" {
  type    = bool
  default = false # Set true only if supported in your region
}
