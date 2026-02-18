###############################################################
# Outputs for Multi-Cloud Active-Active Deployment
# Exposes the service endpoints from Azure, GCP, and Traffic Manager
###############################################################

# Output the default Azure App Service URL
output "azure_app_url" {
  value       = "https://${azurerm_linux_web_app.r4.default_hostname}"
  description = "Azure App Service default URL"
  # Example: https://app-r4-activeactive.azurewebsites.net
}

# Output the Google Cloud Run service URL
output "cloud_run_url" {
  value       = google_cloud_run_v2_service.r4.uri
  description = "Google Cloud Run service URL"
  # Example: https://hello-r4-xyz.a.run.app
}

# Output the global Traffic Manager endpoint
output "traffic_manager_fqdn" {
  value       = azurerm_traffic_manager_profile.r4.fqdn
  description = "Global Traffic Manager DNS name"
  # Example: tm-r4-abc123.trafficmanager.net
  # This DNS name routes traffic between Azure and GCP based on performance
}
