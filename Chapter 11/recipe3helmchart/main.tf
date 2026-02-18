# Install WordPress chart from Bitnami repo using the correct 'set' argument list
resource "helm_release" "wordpress" {
  name       = "wordpress"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "wordpress"
  version    = "15.2.5"
  namespace  = "default"

  set = [
    {
      name  = "service.type"
      value = "LoadBalancer"
    },
    {
      name  = "wordpressUsername"
      value = "admin"
    },
    {
      name  = "wordpressPassword"
      value = "admin123"
    },
    {
      name  = "mariadb.auth.rootPassword"
      value = "mysqlrootpass"
    }
  ]
}