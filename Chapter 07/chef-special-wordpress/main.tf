module "network" {
  source        = "./modules/network"
  region        = var.region
  rg_name       = "chef-wordpress-rg"
  vnet_name     = "chefwp-vnet"
  address_space = ["10.60.0.0/16"]

  subnet_map = {
    web = "10.60.1.0/24"
  }
}

module "data" {
  source      = "./modules/data"
  region      = var.region
  rg_name     = "chef-wordpress-rg"
  db_password = var.db_password
}

module "web" {
  source              = "./modules/web"
  region              = var.region
  rg_name             = "chef-wordpress-rg"
  subnet_id           = module.network.subnet_ids["web"]
  ssh_public_key_path = var.ssh_public_key_path
}

module "frontend" {
  source   = "./modules/frontend"
  region   = var.region
  rg_name  = "chef-wordpress-rg"
}