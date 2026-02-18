# Generate a random ID to ensure global uniqueness of the storage account name
resource "random_id" "id" {
  byte_length = 4
}

# Resource Group to hold all CDN and storage resources
resource "azurerm_resource_group" "rg" {
  name     = "ch6-r5-rg"
  location = var.region
}

# Storage Account with Static Website Hosting enabled
resource "azurerm_storage_account" "sa" {
  name                     = "chs${random_id.id.hex}"  # Must be globally unique
  location                 = var.region
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Enable static website hosting with index.html as landing page
  static_website {
    index_document = "index.html"
  }
}

# Azure CDN Profile (Standard Microsoft)
resource "azurerm_cdn_profile" "profile" {
  name                = "cdnProfile1"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard_Microsoft"
}

# Azure CDN Endpoint mapped to the storage account's static site
resource "azurerm_cdn_endpoint" "endpoint" {
  name                = "cdn-endpoint"
  profile_name        = azurerm_cdn_profile.profile.name
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  origin_host_header  = azurerm_storage_account.sa.primary_web_host

  origin {
    name      = "staticorigin"
    host_name = azurerm_storage_account.sa.primary_web_host
  }

  is_http_allowed  = true
  is_https_allowed = true

  # Ensures the CDN endpoint waits for the storage account to be ready
  depends_on = [azurerm_storage_account.sa]
}
