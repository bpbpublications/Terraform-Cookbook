provider "azurerm" {
  features {}
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}