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

# Resource Group for the Windows VM
resource "azurerm_resource_group" "rg" {
  name     = "ch5-r4-rg"
  location = var.region
}

# Virtual Network and Subnet
resource "azurerm_virtual_network" "vnet" {
  name                = "ch5-r4-vnet"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group to allow RDP
resource "azurerm_network_security_group" "nsg" {
  name                = "ch5-r4-nsg"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-RDP-In"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"  # Consider restricting to your IP for security
    destination_address_prefix = "*"
  }
}

# Network Interface with NSG and Public IP
resource "azurerm_public_ip" "pip" {
  name                = "ch5-r4-pip"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "ch5-r4-nic"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "vm" {
  name                = "ch5-r4-vm"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_size

  admin_username  = "AzureAdmin"
  admin_password  = var.admin_password

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = {
    Environment = "Dev"
    Recipe      = "5-4-windows-vm"
  }
}
