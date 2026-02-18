# Random suffix for globally unique names
resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

# 1) Network: RG, VNet, private subnets, locked-down NSGs
module "network" {
  source          = "./modules/network"
  location        = var.location
  resource_prefix = "${var.resource_prefix}-${random_string.suffix.result}"
  default_tags    = var.default_tags
}

# 2) Secrets: Key Vault with RBAC, secret seed, role for VM identity
module "secrets" {
  source          = "./modules/secrets"
  location        = var.location
  resource_prefix = "${var.resource_prefix}-${random_string.suffix.result}"
  default_tags    = var.default_tags
}

# 3) Compute: Private VM with no public IP. VM fetches secret at boot using its managed identity.
module "compute" {
  source              = "./modules/compute"
  location            = var.location
  resource_prefix     = "${var.resource_prefix}-${random_string.suffix.result}"
  default_tags        = var.default_tags
  rg_name             = module.network.rg_name
  subnet_id           = module.network.app_subnet_id
  nsg_id              = module.network.app_nsg_id
  admin_username      = var.admin_username
  ssh_public_key_path = var.ssh_public_key_path

  # Inputs from secrets module (no secret value, only metadata/URI)
  secret_uri          = module.secrets.secret_uri
  key_vault_name      = module.secrets.key_vault_name
}

# 4) Role assignment
# Grants the VM system-assigned identity permission to read secrets.
resource "azurerm_role_assignment" "kv_reader" {
  scope                = module.secrets.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.compute.vm_identity_principal_id
}