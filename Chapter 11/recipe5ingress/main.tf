# Deploy a sample backend application in a dedicated namespace
resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo"
  }
}

resource "kubernetes_deployment" "echo" {
  metadata {
    name      = "echo-server"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "echo"
      }
    }

    template {
      metadata {
        labels = {
          app = "echo"
        }
      }

      spec {
        container {
          name  = "echo"
          image = "ealen/echo-server"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "echo" {
  metadata {
    name      = "echo-service"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }

  spec {
    selector = {
      app = "echo"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

# Create an Ingress resource to route traffic to the echo-service
resource "kubernetes_ingress_v1" "echo_ingress" {
  metadata {
    name      = "echo-ingress"
    namespace = kubernetes_namespace.demo.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      http {
        path {
          path     = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.echo.metadata[0].name
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