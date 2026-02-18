provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "azure_rg" {
  name     = "multi-cloud-rg-azure"
  location = "uksouth"
}

resource "azurerm_public_ip" "azure_lb_ip" {
  name                = "azure-multi-lb-ip"
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "azure_lb" {
  name                = "azure-multi-lb"
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "azure-fe"
    public_ip_address_id = azurerm_public_ip.azure_lb_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "azure_pool" {
  name            = "azure-backend-pool"
  loadbalancer_id = azurerm_lb.azure_lb.id
}

resource "azurerm_lb_probe" "azure_probe" {
  name            = "azure-http-probe"
  loadbalancer_id = azurerm_lb.azure_lb.id
  protocol        = "Tcp"
  port            = 80
  interval_in_seconds = 15
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "azure_rule" {
  name                           = "azure-http-rule"
  loadbalancer_id                = azurerm_lb.azure_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "azure-fe"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.azure_pool.id]
  probe_id                       = azurerm_lb_probe.azure_probe.id
}

resource "azurerm_virtual_network" "azure_vnet" {
  name                = "azure-multi-vnet"
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "azure_subnet" {
  name                 = "azure-multi-subnet"
  resource_group_name  = azurerm_resource_group.azure_rg.name
  virtual_network_name = azurerm_virtual_network.azure_vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "azure_vmss" {
  name                = "azure-multi-vmss"
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name
  sku                 = "Standard_B2s"
  instances           = 2
  admin_username      = "azureuser"

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
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name      = "ipconfig"
      subnet_id = azurerm_subnet.azure_subnet.id

      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.azure_pool.id
      ]
      primary = true
    }
  }

  custom_data = base64encode(<<-EOF
              #cloud-config
              packages:
                - nginx
              runcmd:
                - sed -i 's/Welcome to nginx!/Welcome from Azure VMSS instance/' /var/www/html/index.nginx-debian.html
                - systemctl enable nginx --now
              EOF
  )

  tags = {
    cluster = "azure"
  }
}
