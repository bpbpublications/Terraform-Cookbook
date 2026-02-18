# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-bluegreen-example"
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-bluegreen"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Application Gateway Subnet (Dedicated)
resource "azurerm_subnet" "agw_subnet" {
  name                 = "agw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# VM Scale Set Subnet (Dedicated)
resource "azurerm_subnet" "vm_subnet" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  
  # Required for VM Scale Sets
  service_endpoints = ["Microsoft.Storage"]
}

# Network Security Group (Allow HTTP/SSH)
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-bluegreen"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-ssh"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with VM subnet
resource "azurerm_subnet_network_security_group_association" "vm_nsg" {
  subnet_id                 = azurerm_subnet.vm_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Public IP for Application Gateway
resource "azurerm_public_ip" "agw_ip" {
  name                = "pip-agw-bluegreen"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Application Gateway (Traffic Router)
resource "azurerm_application_gateway" "agw" {
  name                = "agw-bluegreen"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 2
  }

  gateway_ip_configuration {
    name      = "agw-ip-config"
    subnet_id = azurerm_subnet.agw_subnet.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "agw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.agw_ip.id
  }

  # Backend pools for blue/green environments
  backend_address_pool {
    name = "blue-pool"
  }

  backend_address_pool {
    name = "green-pool"
  }

  # Backend HTTP settings
  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  # HTTP listener
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "agw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  # Routing rule (points to active environment)
  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "${var.env_prefix}-pool"
    backend_http_settings_name = "http-settings"
  }
}

# Scale Set for Active Environment (Blue/Green)
resource "azurerm_linux_virtual_machine_scale_set" "active" {
  name                = "vmss-${var.env_prefix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard_B1ms"
  instances           = var.vm_count
  admin_username      = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "nic-${var.env_prefix}"
    primary = true

    ip_configuration {
      name      = "ipconfig"
      primary   = true
      subnet_id = azurerm_subnet.vm_subnet.id

      # Attach to Application Gateway backend pool
      application_gateway_backend_address_pool_ids = [
        one([
          for pool in azurerm_application_gateway.agw.backend_address_pool : 
          pool.id if pool.name == "${var.env_prefix}-pool"
        ])
      ]
    }
  }

  # Install web server and version tag
  custom_data = base64encode(<<EOF
#!/bin/bash
apt-get update
apt-get install -y apache2
echo "<h1>${var.env_prefix} Environment (${var.app_version})</h1>" > /var/www/html/index.html
systemctl restart apache2
EOF
  )

  # Tag instances for identification
  tags = {
    Environment = var.env_prefix
    Version     = var.app_version
  }
}