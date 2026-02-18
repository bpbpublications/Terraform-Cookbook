# Name of the resource group
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-chapter9-vmss"
}

# Azure region for deployment
variable "location" {
  description = "Azure region in which to deploy resources"
  type        = string
  default     = "eastus"
}

# VNet and subnet configuration
variable "vnet_address_space" {
  description = "CIDR block for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}
variable "subnet_prefix" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Load Balancer configuration
variable "public_ip_name" {
  description = "Name of the public IP resource for the LB"
  type        = string
  default     = "pip-vmss-lb"
}
variable "lb_name" {
  description = "Name of the Load Balancer"
  type        = string
  default     = "lb-vmss"
}
variable "frontend_ip_configuration_name" {
  description = "Name for the LB front-end IP configuration"
  type        = string
  default     = "fe-config"
}
variable "backend_address_pool_name" {
  description = "Name for the LB backend address pool"
  type        = string
  default     = "be-pool"
}

# VM Scale Set sizing
variable "vm_size" {
  description = "SKU for each VM instance"
  type        = string
  default     = "Standard_B1ms"
}
variable "initial_capacity" {
  description = "Initial number of VM instances"
  type        = number
  default     = 2
}
variable "min_capacity" {
  description = "Minimum number of VM instances to maintain"
  type        = number
  default     = 1
}
variable "max_capacity" {
  description = "Maximum number of VM instances allowed"
  type        = number
  default     = 5
}

# Autoscale CPU threshold
variable "cpu_threshold" {
  description = "CPU utilisation percentage that triggers scaling"
  type        = number
  default     = 75
}

# SSH access
variable "admin_username" {
  description = "Username for SSH access on each VM"
  type        = string
  default     = "azureuser"
}
variable "admin_ssh_public_key_path" {
  description = "Local path to the SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
