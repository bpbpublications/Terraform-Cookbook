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
  name     = "chef-drift-rg"
  location = var.region
}

# Virtual Network and Subnet (minimal network)
resource "azurerm_virtual_network" "vnet" {
  name                = "chef-drift-vnet"
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
  name                = "chef-drift-nic"
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
  name                = "chef-drift-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.region
  size                = var.vm_size

  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_username        = "azureuser"
  disable_password_authentication = true

  # Provide SSH key so VM can be created without password
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

# Managed data disk
resource "azurerm_managed_disk" "data" {
  name                 = "chef-drift-disk"
  location             = var.region
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.disk_size_gb
}

# Attach the data disk to the VM
resource "azurerm_virtual_machine_data_disk_attachment" "attach" {
  managed_disk_id    = azurerm_managed_disk.data.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = 10
  caching            = "None"
}

output "data_disk_uri" {
  description = "URI of the managed data disk"
  value       = azurerm_managed_disk.data.id
}