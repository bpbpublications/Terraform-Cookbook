# Create a separate namespace for the Nginx app deployment
resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "nginx"
  }
}

# Define a Deployment to run 2 replicas of the official Nginx container
resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx-deployment"
    namespace = kubernetes_namespace.nginx.metadata[0].name  # Correct indexing for metadata block
  }

  spec {
    replicas = 2  # Number of pod replicas

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"  # Nginx Docker image from Docker Hub

          port {
            container_port = 80  # Expose port 80 inside the container
          }
        }
      }
    }
  }
}

# Expose the Nginx deployment externally using a LoadBalancer service
resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx-service"
    namespace = kubernetes_namespace.nginx.metadata[0].name  # Correct indexing for metadata block
  }

  spec {
    selector = {
      app = "nginx"  # Match pods with label "app = nginx"
    }

    port {
      port        = 80         # Port exposed by the service
      target_port = 80         # Port exposed by the container
    }

    type = "LoadBalancer"       # Service type for external access
  }
}