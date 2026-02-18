terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a new Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.region
}

# Create the AKS cluster in the resource group
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "ch11aks"

  default_node_pool {
    name       = "default"            # Default node pool name
    node_count = var.node_count       # Number of nodes in the pool
    vm_size    = var.node_vm_size     # VM size per node
  }

  identity {
    type = "SystemAssigned"           # Enable managed identity for the cluster
  }
}

# Output the raw kubeconfig for connecting to the AKS cluster
# This output will be marked sensitive and will not be displayed directly in the terminal
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}