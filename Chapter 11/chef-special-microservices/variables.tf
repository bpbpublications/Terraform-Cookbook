variable "location" {
  default = "East US"
}

variable "resource_group_name" {
  default = "chef-rg"
}

variable "cluster_name" {
  default = "chef-aks"
}

variable "kubeconfig_path" {
  type = string
}