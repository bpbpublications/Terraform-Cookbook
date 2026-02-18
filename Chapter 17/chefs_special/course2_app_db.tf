############################################
# App resource group and internal Load Balancer
############################################

resource "azurerm_resource_group" "app" {
  name     = "rg-app-${local.name_suffix}"
  location = var.location_primary
  tags     = local.tags
}

resource "azurerm_lb" "ilb" {
  name                = "ilb-${local.name_suffix}"
  location            = var.location_primary
  resource_group_name = azurerm_resource_group.app.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "ilb-fe"
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.subnet_app_cidr, 10)
    subnet_id                     = azurerm_subnet.app.id
  }

  tags = local.tags
}

resource "azurerm_lb_backend_address_pool" "bepool" {
  name            = "bepool"
  loadbalancer_id = azurerm_lb.ilb.id
}

resource "azurerm_lb_probe" "probe" {
  name            = "tcp-80"
  loadbalancer_id = azurerm_lb.ilb.id
  protocol        = "Tcp"
  port            = 80
  interval_in_seconds = 15
  number_of_probes    = 2
}

# Load-balancing rule: EXPLICITLY tie to backend pool + probe
resource "azurerm_lb_rule" "http80" {
  name                           = "rule-80"
  loadbalancer_id                = azurerm_lb.ilb.id
  frontend_ip_configuration_name = "ilb-fe"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bepool.id]
  probe_id                       = azurerm_lb_probe.probe.id
}

############################################
# VM Scale Set across zones with rolling upgrades
############################################

# Simple cloud-init to install NGINX and serve a test page
locals {
  cloud_init = <<-EOT
  #cloud-config
  package_update: true
  packages:
    - nginx
  runcmd:
    - echo "Chef's Special is running" > /var/www/html/index.nginx-debian.html
    - systemctl enable nginx
    - systemctl restart nginx
  EOT
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                            = "vmss-${local.name_suffix}"
  location                        = var.location_primary
  resource_group_name             = azurerm_resource_group.app.name
  sku                             = var.vmss_sku
  instances                       = var.vmss_instances
  zones                           = ["1", "2", "3"] # spread across zones for resiliency
  admin_username                  = var.admin_username
  disable_password_authentication = true
  custom_data                     = base64encode(local.cloud_init)

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    disk_size_gb         = 64
  }

  
  network_interface {
    name    = "nic-primary"
    primary = true

    ip_configuration {
      name      = "ipconfig"
      primary   = true
      subnet_id = azurerm_subnet.app.id

      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.bepool.id
      ]
    }
  }

  # Ensure LB rule exists before VMSS binds the probe
  depends_on = [azurerm_lb_rule.http80]

  # Ensure safe zero-downtime rollouts
  upgrade_mode = "Rolling"
  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }

  # Attach user assigned identity for future Key Vault or storage access
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uami_app.id]
  }

  # Health probe for the scale set
  health_probe_id = azurerm_lb_probe.probe.id

  tags = local.tags
}

############################################
# Database resource group, SQL Server, Private Endpoint and DB
############################################

resource "azurerm_resource_group" "db" {
  name     = "rg-db-${local.name_suffix}"
  location = var.location_primary
  tags     = local.tags
}

# Unique server name with suffix
resource "random_string" "sqlsuffix" {
  length  = 4
  lower   = true
  numeric = true
  upper   = false
  special = false
}

resource "azurerm_mssql_server" "sql" {
  name                          = "sql-${random_string.sqlsuffix.result}"
  resource_group_name           = azurerm_resource_group.db.name
  location                      = var.location_primary
  version                       = "12.0"
  administrator_login           = var.sql_admin_login
  administrator_login_password  = random_password.sql_admin_password.result
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false # enforce private access
  tags                          = local.tags
}

# Private DNS zone for SQL, linked to the VNet
resource "azurerm_private_dns_zone" "sql_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.db.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_link" {
  name                  = "sql-vnet-link"
  resource_group_name   = azurerm_resource_group.db.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags                  = local.tags
}

# Private endpoint into the data subnet
resource "azurerm_private_endpoint" "sql_pe" {
  name                = "pe-${azurerm_mssql_server.sql.name}"
  location            = var.location_primary
  resource_group_name = azurerm_resource_group.db.name
  subnet_id           = azurerm_subnet.data.id
  tags                = local.tags

  private_service_connection {
    name                           = "sql-conn"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "sql-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_zone.id]
  }
}

# The application database
resource "azurerm_mssql_database" "db" {
  name                                = "appdb"
  server_id                           = azurerm_mssql_server.sql.id
  sku_name                            = var.sql_sku_name
  zone_redundant                      = var.sql_zone_redundant # keep false unless supported
  geo_backup_enabled                  = true
  transparent_data_encryption_enabled = true
  tags                                = local.tags
}

# Store a ready-to-use connection string in Key Vault for apps
resource "azurerm_key_vault_secret" "sql_connection_string" {
  name         = "sql-connection-string"
  key_vault_id = azurerm_key_vault.kv.id
  value        = "Server=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.db.name};User ID=${var.sql_admin_login};Password=${random_password.sql_admin_password.result};Encrypt=true;Connection Timeout=30;"
}

