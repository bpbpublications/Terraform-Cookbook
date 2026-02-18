resource "azurerm_resource_group" "demo" {
  name     = "orchestration-demo-rg"
  location = var.location
}

# Network resources for VM
resource "azurerm_virtual_network" "demo_vnet" {
  name                = "demo-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name
}
resource "azurerm_subnet" "demo_subnet" {
  name                 = "demo-subnet"
  resource_group_name  = azurerm_resource_group.demo.name
  virtual_network_name = azurerm_virtual_network.demo_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_public_ip" "demo_ip" {
  name                = "demo-publicip"
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name
  allocation_method   = "Dynamic"

# ← this makes demo-abc.eastus.cloudapp.azure.com
  domain_name_label = "demo-${random_string.vm_name_suffix.result}"
}

resource "azurerm_network_security_group" "demo_nsg" {
  name                = "demo-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
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
}

resource "azurerm_network_interface" "demo_nic" {
  name                = "demo-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.demo_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.demo_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "demo_nic_nsg" {
  network_interface_id      = azurerm_network_interface.demo_nic.id
  network_security_group_id = azurerm_network_security_group.demo_nsg.id
}

# Generate a random name suffix for the VM to ensure unique DNS if needed
resource "random_string" "vm_name_suffix" {
  length  = 3
  special = false
  upper   = false
}

resource "azurerm_linux_virtual_machine" "demo_vm" {
  name                = "demo-vm-${random_string.vm_name_suffix.id}"
  resource_group_name = azurerm_resource_group.demo.name
  location            = var.location
  size                = "Standard_B1s"  # small size for demo
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password  # note: this will be stored in state in plain text (sensitive handling recommended)

  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.demo_nic.id]

  os_disk {
    name              = "demo-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = azurerm_public_ip.demo_ip.fqdn
      user     = var.vm_admin_username
      password = var.vm_admin_password
      # If using SSH key, you would specify private_key instead.
      timeout  = "5m"
    }
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y apache2",
      "sudo systemctl enable apache2",
      "sudo systemctl start apache2"
    ]
  }

  provisioner "local-exec" {
    # This will run on the machine Terraform is running on, after VM creation and remote exec.
    command = "echo VM ${self.name} is up and configured. Public IP: ${azurerm_public_ip.demo_ip.ip_address} >> orchestration_log.txt"
  }
}
