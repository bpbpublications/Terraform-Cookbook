# Azure region where the AKS cluster will be deployed
variable "region" {
  type        = string
  default     = "eastus"
}

# Logical name for the AKS cluster
variable "aks_cluster_name" {
  type        = string
  default     = "ch11-aks-cluster"
}

# Number of nodes in the default node pool
variable "node_count" {
  type        = number
  default     = 2
}

# VM size to use for each node
variable "node_vm_size" {
  type        = string
  default     = "Standard_DS2_v2"
}

# Resource group name
variable "resource_group_name" {
  type        = string
  default     = "ch11-rg"
}