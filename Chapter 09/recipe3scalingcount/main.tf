# File: main.tf

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create the Service Plan (new resource type)
resource "azurerm_service_plan" "asp" {
  name                = "${var.resource_group_name}-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # New required attributes
  os_type  = "Windows"             # or "Linux" if you need a Linux plan
  sku_name = var.app_service_plan_sku  # e.g. "S1", "P1v2", etc.
}

# Create multiple App Service instances using count
resource "azurerm_app_service" "app" {
  count               = var.web_count
  name                = "${var.app_service_prefix}${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_service_plan.asp.id  # updated reference

  site_config {
    dotnet_framework_version = "v4.0"
    http2_enabled            = true
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}
