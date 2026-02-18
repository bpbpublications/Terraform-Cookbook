# Create or look up the environment Resource Group
resource "azurerm_resource_group" "env" {
  name     = var.rg_name
  location = var.location

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Bring in shared tags from global-variables (optional)
locals {
  global_tags = {
    Application = "CookbookSample"
    Owner       = "PlatformTeam"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}

# Invoke the network module
module "network" {
  source              = "../../modules/network"
  location            = var.location
  resource_group_name = azurerm_resource_group.env.name
  vnet_cidr           = var.vnet_cidr
  subnet_cidrs        = var.subnet_cidrs
  tags                = local.global_tags
}

# Choose a target subnet for the VM
locals {
  app_subnet_id = module.network.subnet_ids["subnet-app"]
}

# Invoke the compute module
module "compute" {
  source              = "../../modules/compute"
  location            = var.location
  resource_group_name = azurerm_resource_group.env.name
  subnet_id           = local.app_subnet_id
  vm_name             = "dev-vm-01"
  vm_size             = var.vm_size
  ssh_public_key_path = "~/.ssh/id_rsa.pub"
  tags                = local.global_tags
}
