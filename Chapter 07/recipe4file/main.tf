# Create a resource group to contain the storage resources
resource "azurerm_resource_group" "rg" {
  name     = "ch7-r4-rg"         # Name of the resource group
  location = var.region          # Region specified in variables.tf
}

# Generate a 4-character random lowercase string to ensure unique storage account name
resource "random_string" "suffix" {
  length  = 4                    # Total characters in the string
  upper   = false                # No uppercase letters
  numeric = false                # No numbers
  special = false                # No special characters
}

# Provision a premium-tier Azure Storage Account with FileStorage kind
resource "azurerm_storage_account" "storage" {
  name                     = "filestor${random_string.suffix.result}" # Globally unique name using random suffix
  resource_group_name      = azurerm_resource_group.rg.name          # Assign to the resource group above
  location                 = azurerm_resource_group.rg.location      # Same region as the resource group
  account_tier             = "Premium"                               # Required for FileStorage accounts
  account_replication_type = "LRS"                                   # Locally-redundant storage
  account_kind             = "FileStorage"                           # Optimized for Azure Files (not Blob/General Purpose)
}

# Create an Azure File Share inside the storage account
resource "azurerm_storage_share" "fileshare" {
  name                 = "app-share"                                  # Name of the file share
  storage_account_name = azurerm_storage_account.storage.name        # Link to the storage account above
  quota                = 100                                          # Set quota to 100 GB

  depends_on = [azurerm_storage_account.storage]                      # Ensure storage account is created first
}
