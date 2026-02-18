# File: main.tf

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_group_name}-vnet"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.resource_group_name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefix]
}

# Create a public IP for the load balancer
resource "azurerm_public_ip" "pip" {
  name                = var.public_ip_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Basic"
}

# Create the Load Balancer
resource "azurerm_lb" "lb" {
  name                = var.lb_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

# Create the backend address pool
resource "azurerm_lb_backend_address_pool" "bepool" {
  name            = var.backend_address_pool_name
  loadbalancer_id = azurerm_lb.lb.id
}

# Define the Linux VM Scale Set
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.resource_group_name}-vmss"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.vm_size
  instances           = var.initial_capacity

  # SSH authentication
  admin_username = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.admin_ssh_public_key_path)
  }

  # Attach VMs to the subnet and LB backend pool
  network_interface {
    name    = "nic"
    primary = true
    ip_configuration {
      name                                   = "ipconfig"
      subnet_id                              = azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bepool.id]
      primary                                = true
    }
  }

  # Use Ubuntu 18.04 LTS
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # OS disk settings
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

# Configure autoscale settings for the VM Scale Set
resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "${var.resource_group_name}-autoscale"
  resource_group_name = azurerm_resource_group.rg.name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss.id
  location            = azurerm_resource_group.rg.location

  profile {
    name = "autoProfile"

    capacity {
      minimum = var.min_capacity
      maximum = var.max_capacity
      default = var.initial_capacity
    }

    # Scale out when average CPU exceeds threshold
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_namespace   = "Microsoft.Compute/virtualMachineScaleSets"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        time_window        = "PT5M"
        statistic          = "Average"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.cpu_threshold
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    # Scale in when average CPU falls below (threshold - 20)
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_namespace   = "Microsoft.Compute/virtualMachineScaleSets"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        time_window        = "PT5M"
        statistic          = "Average"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.cpu_threshold - 20
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}
