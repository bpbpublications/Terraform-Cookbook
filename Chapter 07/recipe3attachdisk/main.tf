# Resource Group: logical container for all resources in this recipe
resource "azurerm_resource_group" "rg" {
  name     = "ch7-r3-rg"    # Name of the Resource Group
  location = var.region     # Azure region (e.g., "uksouth"), passed in via variable
}

# Virtual Network: defines an isolated, private network
resource "azurerm_virtual_network" "vnet" {
  name                = "r3-vnet"                       # Logical name of the VNet
  address_space       = ["10.30.0.0/16"]                # CIDR block for the VNet
  location            = var.region                      # Same region as the RG
  resource_group_name = azurerm_resource_group.rg.name  # Link to the Resource Group
}

# Subnet: partition within the VNet for placing resources
resource "azurerm_subnet" "subnet" {
  name                 = "r3-subnet"                     # Subnet name
  resource_group_name  = azurerm_resource_group.rg.name   # Link to RG
  virtual_network_name = azurerm_virtual_network.vnet.name  # Link to the VNet
  address_prefixes     = ["10.30.1.0/24"]                # CIDR block for this subnet
}

# Network Interface: attaches networking to a VM
resource "azurerm_network_interface" "nic" {
  name                = "r3-nic"                        # NIC resource name
  location            = var.region                      # Same region
  resource_group_name = azurerm_resource_group.rg.name  # Link to RG

  ip_configuration {
    name                          = "ipconfig"          # IP config block name
    subnet_id                     = azurerm_subnet.subnet.id  # Associate with the subnet
    private_ip_address_allocation = "Dynamic"           # Automatically assign IP
  }
}

# Managed Disk: separate data disk to attach to the VM
resource "azurerm_managed_disk" "datadisk" {
  name                 = "vm-datadisk"                  # Disk name
  location             = azurerm_resource_group.rg.location  # Same location as RG
  resource_group_name  = azurerm_resource_group.rg.name  # Link to RG
  storage_account_type = "Standard_LRS"                 # Locally-redundant storage
  create_option        = "Empty"                        # Create an empty disk
  disk_size_gb         = 128                             # Disk size in GB
}

# Linux VM: a virtual machine running Ubuntu, with SSH key access
resource "azurerm_linux_virtual_machine" "vm" {
  name                         = "vm-for-disk"            # VM name
  resource_group_name          = azurerm_resource_group.rg.name  # Link to RG
  location                     = azurerm_resource_group.rg.location  # Same location
  size                         = "Standard_B1s"           # VM SKU (small, burstable)
  admin_username               = "azureuser"              # Admin user name
  network_interface_ids        = [azurerm_network_interface.nic.id]  # Attach NIC
  disable_password_authentication = true                  # Only allow SSH key

  # SSH key for secure, passwordless login
  admin_ssh_key {
    username   = "azureuser"     # Must match admin_username
    public_key = file("~/.ssh/id_rsa.pub")  # Path to your SSH public key
  }

  # OS disk settings
  os_disk {
    caching              = "ReadWrite"               # Disk caching mode
    storage_account_type = "Standard_LRS"            # Storage redundancy
    name                 = "vm-osdisk"               # OS disk name
  }

  # Base image for the VM
  source_image_reference {
    publisher = "Canonical"       # Official Ubuntu publisher
    offer     = "UbuntuServer"    # Offer name
    sku       = "18.04-LTS"       # Version/SKU of Ubuntu
    version   = "latest"          # Always pull the latest patch
  }
}

# Attach the managed data disk to the VM at LUN 0
resource "azurerm_virtual_machine_data_disk_attachment" "diskattach" {
  managed_disk_id    = azurerm_managed_disk.datadisk.id  # Disk to attach
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id  # Target VM
  lun                = 0                                 # Logical unit number
  caching            = "ReadWrite"                       # Disk caching mode
}
