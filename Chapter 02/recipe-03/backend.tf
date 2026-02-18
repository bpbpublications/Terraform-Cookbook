terraform {
  backend "azurerm" {
    resource_group_name  = "rg-chapter2-demo"
    storage_account_name = "tfstateacctchap2"
    container_name       = "tfstate"
    key                  = "chapter2.tfstate"
  }
}