# ---------------------------------------------------------------------
# Data source: latest Ubuntu 22.04 LTS image from the Azure marketplace.
# ---------------------------------------------------------------------
data "azurerm_platform_image" "ubuntu_latest" {
  location  = var.location
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts"
}

# ---------------------------------------------------------------------
# Data source: existing virtual network and its subnet.
# ---------------------------------------------------------------------
data "azurerm_virtual_network" "existing_vnet" {
  name                = var.existing_vnet_name
  resource_group_name = var.existing_rg
}

data "azurerm_subnet" "existing_subnet" {
  name                 = var.existing_subnet_name
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  resource_group_name  = var.existing_rg
}

# ---------------------------------------------------------------------
# Supporting resource group for the new VM (separate from network RG).
# ---------------------------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-ch10-r3"
  location = var.location
}

# Network Interface attached to the existing subnet
resource "azurerm_network_interface" "nic" {
  name                = "nic-ds-vm"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# New VM referencing the looked‑up image and existing network
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-ds"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B1ms"

  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_username       = "azureuser"
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "disk-ds"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = data.azurerm_platform_image.ubuntu_latest.publisher
    offer     = data.azurerm_platform_image.ubuntu_latest.offer
    sku       = data.azurerm_platform_image.ubuntu_latest.sku
    version   = data.azurerm_platform_image.ubuntu_latest.version
  }
}