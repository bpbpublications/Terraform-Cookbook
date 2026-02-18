# Configure the Azure provider
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
  name     = "ch5-r1-rg"
  location = var.region
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "ch5-r1-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "ch5-r1-nic"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    # No public IP for this VM (private NIC only)
  }
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "ch5-r1-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.region
  size                = var.vm_size

  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic.id]

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

   # Wrap your cloud-init script in base64encode()
  custom_data = base64encode(<<-EOF
    #cloud-config
    write_files:
      - path: /var/tmp/welcome.txt
        content: |
          Hello from Terraform cloud-init!
    EOF
  )
}
