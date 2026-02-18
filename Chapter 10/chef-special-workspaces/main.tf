terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.6"
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

# App Service Plan
resource "azurerm_service_plan" "plan" {
  name                = "${local.prefix}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name            = var.sku   # S1, P1v2, etc.
  os_type             = "Linux"

  tags = local.common_tags
}

# Loop to create N web apps
resource "azurerm_linux_web_app" "app" {
  count               = var.instance_count               # 1 in dev, 3 in prod
  name                = format("%s-%02d", local.prefix, count.index + 1)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  tags = merge(
    local.common_tags,
    { instance = count.index + 1 }                       # dev-web-01, dev-web-02 …
  )
}

# Optional monitoring resource (created only when flag is true)
resource "azurerm_application_insights" "ai" {
  count               = var.enable_advanced_monitoring ? 1 : 0
  name                = "${local.prefix}-ai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"   
  tags                = local.common_tags
}
