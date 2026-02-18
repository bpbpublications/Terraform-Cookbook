module "common" {
  source            = "./modules/common"
  location          = var.location
  resource_prefix   = var.resource_prefix
  vm_admin_username = var.vm_admin_username
  vm_size           = var.vm_size
  ssh_public_key_path = var.ssh_public_key_path
}
