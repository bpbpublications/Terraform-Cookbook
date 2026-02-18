terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.27.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "null_resource" "hello" {
  provisioner "local-exec" {
    command = "echo 'Hello, Terraform!'"
  }
}