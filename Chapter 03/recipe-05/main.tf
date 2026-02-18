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

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "ch3-r5-rg"
  location = var.region
}

# Virtual Network and Subnet (minimal network)
resource "azurerm_virtual_network" "vnet" {
  name                = "ch3-r5-vnet"
  address_space       = ["10.5.0.0/16"]
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.5.1.0/24"]
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "ch3-r5-nic"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Linux VM with both SSH and password auth (password value is masked)
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "ch3-r5-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.region
  size                = var.vm_size

  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_username        = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.admin_public_key
  }

  disable_password_authentication = false
  admin_password                  = var.admin_password  # Sensitive var masks value

  os_disk {
    name                 = "ch3-r5-osdisk"
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

output "vm_admin_password" {
  value     = var.admin_password
  sensitive = true
}