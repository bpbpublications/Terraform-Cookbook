# Create Azure resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create Azure Kubernetes Service (AKS) cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "chef"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "standard_a2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [azurerm_resource_group.rg] # <-- This ensures RG is available
}

# Output kubeconfig to connect with kubectl
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

# Frontend microservice deployment
resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }
      spec {
        container {
          name  = "frontend"
          image = "nginxdemos/hello" # Static HTML demo site
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Internal service for frontend
resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend"
  }
  spec {
    selector = {
      app = "frontend"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}

# API microservice deployment
resource "kubernetes_deployment" "api" {
  metadata {
    name = "api"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "api"
      }
    }
    template {
      metadata {
        labels = {
          app = "api"
        }
      }
      spec {
        container {
          name  = "api"
          image = "ealen/echo-server" # Simple echo API server
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Internal service for API
resource "kubernetes_service" "api" {
  metadata {
    name = "api"
  }
  spec {
    selector = {
      app = "api"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}

# Redis database deployment
resource "kubernetes_deployment" "redis" {
  metadata {
    name = "redis"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "redis"
      }
    }
    template {
      metadata {
        labels = {
          app = "redis"
        }
      }
      spec {
        container {
          name  = "redis"
          image = "redis" # Official Redis image
          port {
            container_port = 6379
          }
        }
      }
    }
  }
}

# Internal service for Redis
resource "kubernetes_service" "redis" {
  metadata {
    name = "redis"
  }
  spec {
    selector = {
      app = "redis"
    }
    port {
      port        = 6379
      target_port = 6379
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "frontend_ingress" {
  metadata {
    name = "frontend-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }
  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.frontend.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}