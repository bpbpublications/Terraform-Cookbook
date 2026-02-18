# Provider block for Kubernetes to access the AKS cluster using the saved kubeconfig file
provider "kubernetes" {
  config_path = var.kubeconfig_path
}