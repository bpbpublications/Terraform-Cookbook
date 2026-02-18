terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  # Read and parse the JSON file
  env_config = jsondecode(file("${path.module}/environments.json"))
  # Convert list of env objects to a map for for_each, using env name as key
  env_map = { for env in local.env_config : env.name => env }
}

resource "azurerm_resource_group" "env" {
  for_each = local.env_map
  name     = "${each.key}-rg"         # e.g., "dev-rg", "prod-rg"
  location = var.location

  tags = {
    Owner       = each.value.owner
    CostCenter  = each.value.cost_center
    Environment = each.key
  }
}
