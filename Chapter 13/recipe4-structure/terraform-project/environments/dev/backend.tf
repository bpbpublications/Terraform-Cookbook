# Remote state for dev. Uses Azure Storage as the backend with state locking.
# Replace placeholders with your actual RG, Storage Account, and Container.

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-demo"
    storage_account_name = "tfstatee5d4246"   # must be 3–24 chars, lowercase and numbers only
    container_name       = "tfstate"
    key                  = "env/dev/terraform.tfstate"
  }
}
