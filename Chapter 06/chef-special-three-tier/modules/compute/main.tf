# Define per-tier configuration for web, app, and db layers
locals {
  tier_config = {
    web = {
      subnet_id      = var.subnet_ids["web"]             # Web subnet ID
      vm_name        = "web-vm"                          # Name of the web VM
      nsg_name       = "web-nsg"                         # NSG name for web tier
      ports          = [22, 80, 443]                     # Allowed inbound ports: SSH, HTTP, HTTPS
      source_address = "*"                               # Allow from internet
    }
    app = {
      subnet_id      = var.subnet_ids["app"]             # App subnet ID
      vm_name        = "app-vm"
      nsg_name       = "app-nsg"
      ports          = [8080]                            # App listens on port 8080
      source_address = var.subnet_cidrs["web"]           # Allow traffic from web subnet only
    }
    db = {
      subnet_id      = var.subnet_ids["db"]              # DB subnet ID
      vm_name        = "db-vm"
      nsg_name       = "db-nsg"
      ports          = [1433]                            # SQL Server default port
      source_address = var.subnet_cidrs["app"]           # Allow traffic from app subnet only
    }
  }
}

# Create Network Security Groups (NSGs) for each tier
resource "azurerm_network_security_group" "nsgs" {
  for_each            = local.tier_config
  name                = each.value.nsg_name
  location            = var.region
  resource_group_name = var.rg_name
}

# Create inbound security rules per NSG based on the tier's configuration
resource "azurerm_network_security_rule" "rules" {
  for_each = {
    for tier, config in local.tier_config :
    "${tier}" => config
  }

  name                        = "allow-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = each.value.ports
  source_address_prefix       = each.value.source_address
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.nsgs[each.key].name
}

# Create NICs for each VM and associate with the correct subnet
resource "azurerm_network_interface" "nics" {
  for_each            = local.tier_config
  name                = "${each.value.vm_name}-nic"
  location            = var.region
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Attach the appropriate NSG to each NIC
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  for_each = local.tier_config

  network_interface_id      = azurerm_network_interface.nics[each.key].id
  network_security_group_id = azurerm_network_security_group.nsgs[each.key].id
}

# Create Linux virtual machines in each tier with SSH key authentication
resource "azurerm_linux_virtual_machine" "vms" {
  for_each            = local.tier_config
  name                = each.value.vm_name
  location            = var.region
  resource_group_name = var.rg_name
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.nics[each.key].id
  ]

  # Load public SSH key from specified file
  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key_path)
  }

  # Define OS disk for each VM
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${each.value.vm_name}-osdisk"
  }

  # Use latest Ubuntu 22.04 LTS image from Canonical
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
