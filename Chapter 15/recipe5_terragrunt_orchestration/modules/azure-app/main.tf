###############################################################
# Terraform Settings
###############################################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm" # AzureRM provider
      version = ">= 4.0.0"          # Require v4.0.0 or newer
    }
  }
}

# Note: The actual provider block will be injected by Terragrunt
# so you do not configure authentication here directly.

###############################################################
# Azure Resource Group
###############################################################

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.app_name}" # Resource Group name with app prefix
  location = var.az_location      # Deployment region
}

###############################################################
# Azure App Service Plan
###############################################################

resource "azurerm_service_plan" "plan" {
  name                = "asp-${var.app_name}"       # Service Plan name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"                     # App Service on Linux
  sku_name            = "B1"                        # Basic pricing tier (1 instance)
  # Note: Upgrade to P1v3 or higher in production for scaling/HA
}

###############################################################
# Azure Linux Web App (Container-based)
###############################################################

resource "azurerm_linux_web_app" "app" {
  name                = "app-${var.app_name}"       # Web App name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true                        # Enforce HTTPS for security

  site_config {
    application_stack {
      docker_image_name = var.azure_container_image # Container image to deploy
      # Example: "nginx:latest" or custom image from ACR
    }
  }
}
