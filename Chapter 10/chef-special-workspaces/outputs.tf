output "app_urls" {
  value = [for app in azurerm_linux_web_app.app : app.default_hostname]
}
