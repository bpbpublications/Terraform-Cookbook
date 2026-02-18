###############################################################
# Azure Traffic Manager Profile for Active-Active Deployment
# Distributes traffic between Azure App Service and GCP Cloud Run
###############################################################

# Generate a random DNS suffix to ensure global uniqueness
resource "random_string" "dns_suffix" {
  length  = 6     # Length of suffix
  upper   = false # Use only lowercase
  special = false # Exclude special characters
}

# Create the Traffic Manager profile
resource "azurerm_traffic_manager_profile" "r4" {
  name                   = "tm-r4-${random_string.dns_suffix.result}" # Unique Traffic Manager profile name
  resource_group_name    = azurerm_resource_group.r4.name
  traffic_routing_method = "Performance" # Route users to the endpoint with lowest latency

  # DNS configuration for the Traffic Manager profile
  dns_config {
    relative_name = "tm-r4-${random_string.dns_suffix.result}" # DNS prefix (FQDN will be *.trafficmanager.net)
    ttl           = 30                                         # DNS TTL (in seconds)
  }

  # Health probe configuration
  monitor_config {
    protocol = "HTTPS" # Probe protocol
    port     = 443     # Probe port
    path     = "/"     # Probe path (root of app)
  }
}

###############################################################
# Azure Endpoint - App Service
###############################################################

resource "azurerm_traffic_manager_azure_endpoint" "azure_app" {
  name       = "azure-app"                           # Endpoint name
  profile_id = azurerm_traffic_manager_profile.r4.id # Link to TM profile

  target_resource_id = azurerm_linux_web_app.r4.id # Target is the Azure App Service
  weight             = 50                          # Equal weight distribution
  priority           = 1                           # Priority for failover (equal for both endpoints here)
}

###############################################################
# External Endpoint - GCP Cloud Run
###############################################################

resource "azurerm_traffic_manager_external_endpoint" "gcp_run" {
  name       = "gcp-cloud-run"                       # Endpoint name
  profile_id = azurerm_traffic_manager_profile.r4.id # Link to TM profile

  # Cloud Run service URI includes "https://", but Traffic Manager only accepts hostnames
  target = replace(google_cloud_run_v2_service.r4.uri, "https://", "")

  weight   = 50 # Equal weight distribution with Azure
  priority = 1  # Same priority as Azure for Active-Active
}
