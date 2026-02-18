terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group for the scale set and LB
resource "azurerm_resource_group" "rg" {
  name     = "ch5-r2-rg"
  location = "uksouth"
}

# Virtual Network and Subnet for the scale set VMs
resource "azurerm_virtual_network" "vnet" {
  name                = "ch5-r2-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP for the Load Balancer (static to use in DNS or outputs)
resource "azurerm_public_ip" "lb_ip" {
  name                = "ch5-r2-lb-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Load Balancer
resource "azurerm_lb" "lb" {
  name                = "ch5-r2-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "public-fe"
    public_ip_address_id = azurerm_public_ip.lb_ip.id
  }
}

# Backend address pool for the LB
resource "azurerm_lb_backend_address_pool" "lb_pool" {
  name                = "ch5-r2-backendpool"
  loadbalancer_id     = azurerm_lb.lb.id
}

# Health probe on port 80 (HTTP) for the LB
resource "azurerm_lb_probe" "lb_probe" {
  name                = "http-probe"
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 15
  number_of_probes    = 2
}

# Load Balancer rule to distribute HTTP (port 80) traffic
resource "azurerm_lb_rule" "lb_rule" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  backend_address_pool_ids        = [
    azurerm_lb_backend_address_pool.lb_pool.id
  ]

  probe_id                       = azurerm_lb_probe.lb_probe.id
}

# Linux Virtual Machine Scale Set
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "ch5-r2-vmss"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
  sku                 = "Standard_B2s"
  instances           = 2
  admin_username      = "azureuser"

  # Use the same SSH key for all instances in the scale set
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching             = "ReadWrite"
  }

  # Network settings for the scale set VMs
  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      subnet_id = azurerm_subnet.subnet.id

      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.lb_pool.id
      ]
      # Each VM instance will register with the LB backend pool
      primary = true
    }
  }

  # Cloud-init custom data to install Nginx on each VM and start it
  custom_data = base64encode(<<-EOF
    #cloud-config
    packages:
      - nginx
    runcmd:
      - systemctl enable nginx --now
      - sh -c 'echo "Hello from Azure VM $(hostname)" > /var/www/html/index.nginx-debian.html'
    EOF
  )

  tags = {
    Environment = "Dev"
    Recipe      = "5-2-scale-set"
  }
}

