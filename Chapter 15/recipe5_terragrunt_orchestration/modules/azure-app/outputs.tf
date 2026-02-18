###############################################################
# Outputs
###############################################################

# Output the default hostname of the Azure App Service
output "azure_app_hostname" {
  value = azurerm_linux_web_app.app.default_hostname
  # Example: app-tg-app-az.azurewebsites.net
  # Use this value to access the deployed containerized web app.
}
