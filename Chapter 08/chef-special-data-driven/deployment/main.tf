terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.36"
    }
  }
}

provider "local" {}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

module "config" {
  source = "../modules/config"
}

module "infra" {
  source       = "../modules/infra"
  region       = module.config.region
  environments = module.config.environments
  rg_name      = "chef-special-rg"
}


resource "local_file" "notification" {
  content  = jsonencode({ status = "success" })
  filename = "${path.root}/modules/notify/output.json"
}

variable "subscription_id" {
  description = "The Azure subscription ID to deploy into"
  type        = string
}
