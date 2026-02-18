# -------------------------------
# Network Foundation Module
# Provisions resource group, VNet, subnets, NAT gateway, and subnet associations
# -------------------------------
module "network" {
  source         = "./modules/network"
  region         = var.region                                 # Deployment region
  rg_name        = "chef-special-rg"                          # Resource group name
  vnet_name      = "chef-vnet"                                # Virtual Network name
  address_space  = ["10.40.0.0/16"]                           # VNet CIDR block

  # Subnet definitions for each tier (web, app, db) and a dedicated Gateway subnet
  subnet_map     = {
    web     = "10.40.1.0/24"
    app     = "10.40.2.0/24"
    db      = "10.40.3.0/24"
    gateway = "10.40.254.0/27"                                # Reserved for VPN Gateway
  }
}

# -------------------------------
# Compute & Security Module
# Deploys VMs, NSGs, rules, and NICs for web, app, and db tiers
# -------------------------------
module "compute" {
  source              = "./modules/compute"
  region              = var.region
  rg_name             = module.network.rg_name                # Use same RG from network module
  subnet_ids          = module.network.subnet_ids            # Use subnet IDs created by network module

  # CIDRs for defining NSG source filtering between tiers
  subnet_cidrs = {
    web = "10.40.1.0/24"
    app = "10.40.2.0/24"
    db  = "10.40.3.0/24"
  }

  # SSH public key for admin access to all Linux VMs
  ssh_public_key_path = "C:/Users/huzef/.ssh/id_rsa.pub"      # Update to your actual public key path
}

# -------------------------------
# Load Balancer & VPN Module
# Deploys an Azure Load Balancer for the web tier and a placeholder VPN Gateway
# -------------------------------
module "loadbalancer" {
  source             = "./modules/loadbalancer"
  region             = var.region
  rg_name            = module.network.rg_name

  # Pass NICs from compute module for web VMs to be attached to LB backend pool
  web_vm_nics        = [module.compute.web_vm_nic]

  # Gateway subnet ID required for VPN Gateway provisioning
  gateway_subnet_id  = module.network.subnet_ids["gateway"]
}
