resource "azurerm_public_ip" "app_lb_public" {
  name                = "app-lb-pip"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "app_lb" {
  name                = "app-lb"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.app_lb_public.id
  }
}

resource "azurerm_lb_backend_address_pool" "bepool" {
  name            = "app-bepool"
  loadbalancer_id = azurerm_lb.app_lb.id
}

resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "app-nic-${count.index}"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                         = "internal"
    subnet_id                    = var.app_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "bepool_assoc" {
  count                   = var.vm_count
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = azurerm_network_interface.nic[count.index].ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.bepool.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                  = var.vm_count
  name                   = "app-vm-${count.index}"
  location               = var.location
  resource_group_name    = var.rg_name
  size                   = var.vm_size
  network_interface_ids  = [azurerm_network_interface.nic[count.index].id]
  admin_username         = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.admin_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}