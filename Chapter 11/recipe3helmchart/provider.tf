# Kubernetes provider to connect to the AKS cluster
provider "kubernetes" {
  config_path = var.kubeconfig_path
}

# Helm provider for deploying Helm charts
provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}