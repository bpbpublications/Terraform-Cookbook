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
  name     = "ch3-r1-rg"
  location = var.region
}

# Virtual Network and Subnet
resource "azurerm_virtual_network" "vnet" {
  name                = "ch3-r1-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "ch3-r1-nic"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Linux VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "ch3-r1-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.region
  size                = var.vm_size

  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_username        = "azureuser"

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

resource "azurerm_public_ip" "web" {
  name                = "ch3-r2-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.region
  allocation_method   = "Static"
}

output "web_ip" {
  description = "Public IP for the web server"
  value       = azurerm_public_ip.web.ip_address
}
