###############################################################
# Azure: Small Linux VM Deployment
###############################################################

# Create a Resource Group to contain all Azure resources
resource "azurerm_resource_group" "rg" {
  name     = "rg-ch15-dualcloud"
  location = var.az_location
}

# Create a Virtual Network (VNet) for VM connectivity
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-dualcloud"
  address_space       = ["10.50.0.0/16"]            # Address range for the VNet
  location            = var.az_location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a Subnet inside the VNet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-dualcloud"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.50.1.0/24"]           # Subnet range
}

# Create a Network Security Group (NSG) and allow SSH traffic
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-dualcloud"
  location            = var.az_location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"   # Rule name
    priority                   = 1001    # Priority (lower = evaluated first)
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"     # Allow from all ports
    destination_port_range     = "22"    # SSH
    source_address_prefix      = "*"     # Allow from any source
    destination_address_prefix = "*"     # To any destination
  }
}

# Public IP for the VM (static so DNS can be stable)
resource "azurerm_public_ip" "pip" {
  name                = "pip-dualcloud"
  location            = var.az_location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Interface (NIC) that attaches Subnet + Public IP
resource "azurerm_network_interface" "nic" {
  name                = "nic-dualcloud"
  location            = var.az_location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"          # Auto-assign private IP
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Associate the NIC with the NSG so that rules apply to the VM
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Deploy the Azure Linux VM
resource "azurerm_linux_virtual_machine" "vm_azure" {
  name                  = "vm-azure-ch15"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.az_location
  size                  = "Standard_B1s"              # Small, cost-efficient VM
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]

  # Configure SSH login with public key
  admin_ssh_key {
