###############################################################
# Deploy an Azure Linux Web App (App Service) with Docker image
# Includes Resource Group, App Service Plan, and Web App
###############################################################

# Create a Resource Group to hold all resources
resource "azurerm_resource_group" "r4" {
  name     = "rg-r4-activeactive" # Resource Group name
  location = var.az_location      # Region (e.g., eastus, westeurope)
}

# Create an App Service Plan (Linux-based)
resource "azurerm_service_plan" "r4" {
  name                = "asp-r4-activeactive" # App Service Plan name
  resource_group_name = azurerm_resource_group.r4.name
  location            = azurerm_resource_group.r4.location
  os_type             = "Linux" # OS type (Linux-based plan)
  sku_name            = "B1"    # Pricing tier (Basic, 1 instance)
  # Note: For production, consider "P1v3" or higher for scaling & resilience
}

# Create a Linux Web App in the App Service Plan
resource "azurerm_linux_web_app" "r4" {
  name                = "app-r4-activeactive" # Web App name
  resource_group_name = azurerm_resource_group.r4.name
  location            = azurerm_resource_group.r4.location
  service_plan_id     = azurerm_service_plan.r4.id # Link to App Service Plan

  https_only = true # Enforce HTTPS for all requests

  site_config {
    application_stack {
      # Use a Docker container image (from Docker Hub or Azure Container Registry)
      docker_image_name = var.azure_container_image
      # Example: "nginx:latest" or custom image "myregistry.azurecr.io/myapp:v1"
    }
  }
}
