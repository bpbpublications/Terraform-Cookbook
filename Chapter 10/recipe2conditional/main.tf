# Resource Group (always created)
resource "azurerm_resource_group" "rg" {
  name     = "rg-ch10-r2"
  location = var.location
}

# VNET (created only when enable_backup is true)
resource "azurerm_virtual_network" "vnet" {
  count               = var.enable_backup ? 1 : 0
  name                = "vnet-backup"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.50.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "subnet" {
  count                = var.enable_backup ? 1 : 0
  name                 = "subnet-backup"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = ["10.50.1.0/24"]
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  count               = var.enable_backup ? 1 : 0
  name                = "nic-backup"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[0].id
    private_ip_address_allocation = "Dynamic"
  }
}

# Backup VM (optional)
resource "azurerm_linux_virtual_machine" "backup" {
  count               = var.enable_backup ? 1 : 0

  name                = "backup-vm"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_size

  network_interface_ids = [azurerm_network_interface.nic[0].id]

  admin_username      = "azureuser"
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "disk-backup"
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