############################################
# Resource groups and identity
############################################

resource "azurerm_resource_group" "core" {
  name     = "rg-core-${local.name_suffix}"
  location = var.location_primary
  tags     = local.tags
}

resource "azurerm_user_assigned_identity" "uami_app" {
  name                = "uami-app-${random_string.suffix.result}"
  location            = var.location_primary
  resource_group_name = azurerm_resource_group.core.name
  tags                = local.tags
}

############################################
# Virtual network and subnets
############################################

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.name_suffix}"
  location            = var.location_primary
  resource_group_name = azurerm_resource_group.core.name
  address_space       = var.vnet_address_space
  tags                = local.tags
}

resource "azurerm_subnet" "web" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.core.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_web_cidr]

  timeouts {
    create = "30m"
    read   = "10m"
  }
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.core.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_app_cidr]
}

resource "azurerm_subnet" "data" {
  name                 = "data-subnet"
  resource_group_name  = azurerm_resource_group.core.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_data_cidr]
}

############################################
# NSGs - keep subnet traffic principle of least privilege
############################################

resource "azurerm_network_security_group" "nsg_app" {
  name                = "nsg-app-${local.name_suffix}"
  location            = var.location_primary
  resource_group_name = azurerm_resource_group.core.name
  tags                = local.tags
}

# Allow the Azure Load Balancer to reach the app tier on port 80
resource "azurerm_network_security_rule" "app_allow_lb_80" {
  name                        = "Allow-LB-to-App-80"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "AzureLoadBalancer" # service tag
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.core.name
  network_security_group_name = azurerm_network_security_group.nsg_app.name
}

# Bind NSG to app subnet
resource "azurerm_subnet_network_security_group_association" "app_assoc" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}

resource "azurerm_network_security_group" "nsg_data" {
  name                = "nsg-data-${local.name_suffix}"
  location            = var.location_primary
  resource_group_name = azurerm_resource_group.core.name
  tags                = local.tags
}

# Allow only app subnet to reach SQL on 1433
resource "azurerm_network_security_rule" "data_allow_app_1433" {
  name                        = "Allow-App-to-SQL-1433"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = azurerm_subnet.app.address_prefixes[0]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.core.name
  network_security_group_name = azurerm_network_security_group.nsg_data.name
}

resource "azurerm_subnet_network_security_group_association" "data_assoc" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.nsg_data.id
}

############################################
# NAT Gateway for safe egress from private subnets
############################################

resource "azurerm_public_ip" "nat_pip" {
  name                = "pip-nat-${local.name_suffix}"
  location            = var.location_primary
  resource_group_name = azurerm_resource_group.core.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_nat_gateway" "nat" {
  name                = "nat-${local.name_suffix}"
  location            = var.location_primary
  resource_group_name = azurerm_resource_group.core.name
  sku_name            = "Standard"
  tags                = local.tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat_pip.id
}

# Associate NAT to web and app subnets
resource "azurerm_subnet_nat_gateway_association" "web_nat" {
  subnet_id      = azurerm_subnet.web.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "app_nat" {
  subnet_id      = azurerm_subnet.app.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

############################################
# Key Vault - initially public access enabled so Terraform can seed secrets.
# In production restrict with Private Endpoint and firewall rules.
############################################

resource "random_password" "sql_admin_password" {
  length           = 24
  special          = true
  override_special = "!@#$%^&*()-_=+"
}

resource "azurerm_key_vault" "kv" {
  name                          = "kv-${random_string.suffix.result}"
  location                      = var.location_primary
  resource_group_name           = azurerm_resource_group.core.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  public_network_access_enabled = true # seed secrets first; harden later
  tags                          = local.tags

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
  timeouts {
    create = "60m"
    read   = "10m"
  }
}

data "azurerm_client_config" "current" {}

# Give current principal permissions to manage secrets during bootstrap
resource "azurerm_key_vault_access_policy" "me" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover", "Backup", "Restore"]
}

# Wait for KV data-plane permissions to be usable after policy creation
resource "time_sleep" "kv_policy_propagated" {
  create_duration = "45s"
  depends_on      = [azurerm_key_vault_access_policy.me]
}

# Seed the SQL admin secrets now; the actual SQL resources come in Course 2
# Ensure both secrets wait for the policy to be effective
resource "azurerm_key_vault_secret" "sql_admin_login" {
  name         = "sql-admin-login"
  value        = "sqladmin"
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [time_sleep.kv_policy_propagated]
}

resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  value        = random_password.sql_admin_password.result
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [time_sleep.kv_policy_propagated]
}