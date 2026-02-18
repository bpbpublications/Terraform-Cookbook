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
  triggers = { message = "Hello, Terraform v2!" }
  provisioner "local-exec" {
    command = "echo '${self.triggers.message}'"
  }
}

resource "local_file" "example" {
  filename = "example.txt"
  content  = "Terraform Plan & Apply Demo"
}