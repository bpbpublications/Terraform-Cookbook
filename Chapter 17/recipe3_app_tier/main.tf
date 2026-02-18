############################################################
# main.tf
# Purpose: Create an internal Load Balancer and a Linux VM
#          Scale Set in the app subnet, attach UAMI, and
#          bootstrap a simple web service on port 8080.
############################################################

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.region
  tags     = var.resource_tags
}

#############################################
# Internal Standard Load Balancer (private) #
#############################################
resource "azurerm_lb" "ilb" {
  name                = "ilb-ch17-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  tags                = var.resource_tags

  frontend_ip_configuration {
    name                          = "ilb-fe"
    subnet_id                     = var.app_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ilb_private_ip
  }
}

# Backend pool
resource "azurerm_lb_backend_address_pool" "bepool" {
  name            = "bepool-app"
  loadbalancer_id = azurerm_lb.ilb.id
}

# Health probe on the application port
resource "azurerm_lb_probe" "tcp_probe" {
  name            = "tcp-${var.app_port}"
  loadbalancer_id = azurerm_lb.ilb.id
  port            = var.app_port
  protocol        = "Tcp"
}

# Load Balancer rule mapping frontend to backend port
resource "azurerm_lb_rule" "lb_rule" {
  name                           = "rule-app-${var.app_port}"
  loadbalancer_id                = azurerm_lb.ilb.id
  protocol                       = "Tcp"
  frontend_port                  = var.app_port
  backend_port                   = var.app_port
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bepool.id]
  frontend_ip_configuration_name = "ilb-fe"
  probe_id                       = azurerm_lb_probe.tcp_probe.id
}

#############################################
# Cloud-init to install and run NGINX on 8080
#############################################
locals {
  cloud_init = <<-CLOUDCFG
    #cloud-config
    package_update: true
    packages:
      - nginx
      - curl
    write_files:
      - path: /var/www/html/index.html
        permissions: "0644"
        owner: root:root
        content: |
          <html>
          <head><title>VMSS App</title></head>
          <body>
            <h1>VMSS instance: $(hostname)</h1>
            <p>Listening on port ${var.app_port}</p>
            <p>Key Vault: ${var.key_vault_uri}</p>
          </body>
          </html>
    runcmd:
      - sed -i 's/listen 80 default_server/listen ${var.app_port} default_server/' /etc/nginx/sites-available/default
      - sed -i 's/listen \\[::\\]:80 default_server/listen \\[::\\]:${var.app_port} default_server/' /etc/nginx/sites-available/default
      - systemctl restart nginx
  CLOUDCFG
}

#############################################
# Linux VM Scale Set with UAMI and ILB pool #
#############################################
resource "azurerm_linux_virtual_machine_scale_set" "app_vmss" {
  name                = "vmss-ch17-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku       = "Standard_B2s"
  instances = var.instance_count
  zones     = var.availability_zones
  tags      = var.resource_tags

  # Required OS disk
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    disk_size_gb         = 64
  }

  # Rolling upgrades require a policy block
  upgrade_mode = "Rolling"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20 # upgrade at most 20% of instances per batch
    max_unhealthy_instance_percent          = 20 # allow up to 20% unhealthy overall during upgrade
    max_unhealthy_upgraded_instance_percent = 5  # allow up to 5% unhealthy in the upgraded batch
    pause_time_between_batches              = "PT0S"
  }

  # Use the ILB health probe for upgrade health evaluation
  health_probe_id = azurerm_lb_probe.tcp_probe.id

  # Attach the User Assigned Managed Identity
  identity {
    type         = "UserAssigned"
    identity_ids = [local.uami_id_effective] # from identity_lookup.tf; or use var.uami_id directly if you skipped that file
  }

  # Admin credentials
  admin_username = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  # Base image
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Networking
  network_interface {
    name    = "nic-primary"
    primary = true

    ip_configuration {
      name                                   = "ipconfig"
      primary                                = true
      subnet_id                              = var.app_subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bepool.id]
    }
  }

  # Cloud-init to run NGINX on the chosen app port
  custom_data = base64encode(local.cloud_init)

  # Harden login
  disable_password_authentication = true
}
