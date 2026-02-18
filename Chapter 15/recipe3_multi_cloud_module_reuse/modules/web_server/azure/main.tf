###############################################################
# Terraform Configuration for Deploying a Linux VM on Azure
# Includes networking, security, and cloud-init configuration
###############################################################

# Specify the required provider and version
terraform {
  required_providers {
    azurerm = { 
      source  = "hashicorp/azurerm" # AzureRM provider for Azure resources
      version = ">= 3.0"            # Require version 3.0 or higher
    }
  }
}

# Input variables
variable "name" { type = string }            # Resource name prefix
variable "az_location" { type = string }     # Azure region (e.g., eastus, westeurope)
variable "ssh_public_key" { type = string }  # SSH public key for VM access

# Create a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.name}-az" # Resource group name (dynamic with prefix)
  location = var.az_location
}

# Create a Virtual Network (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.name}"
  address_space       = ["10.81.0.0/16"]   # CIDR block for the VNet
  location            = var.az_location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a Subnet inside the VNet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${var.name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.81.1.0/24"] # Subnet CIDR block
}

# Create a Network Security Group (NSG) with inbound rules
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.name}"
  location            = var.az_location
  resource_group_name = azurerm_resource_group.rg.name

  # Allow inbound HTTP (port 80)
  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow inbound SSH (port 22)
  security_rule {
    name                       = "SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a Public IP address for the VM
resource "azurerm_public_ip" "pip" {
  name                = "pip-${var.name}"
  location            = var.az_location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"   # Assign static IP
  sku                 = "Standard" # Recommended SKU for production workloads
}

# Create a Network Interface (NIC) and attach Public IP + Subnet
resource "azurerm_network_interface" "nic" {
  name                = "nic-${var.name}"
  location            = var.az_location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipcfg"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"     # Automatically assign private IP
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Associate the NIC with the NSG (so rules apply to the VM)
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Cloud-init configuration to bootstrap the VM with Nginx
locals {
  cloud_init = <<-EOT
    #cloud-config
    package_update: true
    packages: [nginx]  # Install Nginx web server
    write_files:
      - path: /var/www/html/index.html
        permissions: '0644'
        owner: root:root
        content: |
          <h1>Hello from Azure</h1>
    runcmd:
      - systemctl enable nginx   # Enable Nginx on startup
      - systemctl restart nginx  # Start Nginx service
  EOT
}

# Create the Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm-${var.name}-az"
  location              = var.az_location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = "Standard_B1s"   # VM size (small, cost-effective)
  admin_username        = "cookbook"       # Default admin username
  network_interface_ids = [azurerm_network_interface.nic.id]

  # Configure SSH access with provided public key
  admin_ssh_key {
    username   = "cookbook"
    public_key = var.ssh_public_key
  }

  # Pass the cloud-init config (must be base64 encoded for Azure API)
  custom_data = base64encode(local.cloud_init)

  # OS disk configuration
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" # Standard locally redundant storage
  }

  # Ubuntu Linux image reference
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
