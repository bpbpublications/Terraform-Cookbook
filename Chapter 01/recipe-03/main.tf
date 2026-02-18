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

resource "local_file" "example" {
  filename = "example.txt"
  content  = "Terraform Plan & Apply Demo"
}