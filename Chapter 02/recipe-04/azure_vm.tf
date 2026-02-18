resource "azurerm_virtual_network" "vnet" {
  name                = "demo-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"
  resource_group_name = "rg-chapter2-demo"
}

resource "azurerm_subnet" "subnet" {
  name                 = "demo-subnet"
  resource_group_name  = "rg-chapter2-demo"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "demo-pip"
  location            = "East US"
  resource_group_name = "rg-chapter2-demo"
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"
}

resource "azurerm_network_interface" "nic" {
  name                = "demo-nic"
  location            = "East US"
  resource_group_name = "rg-chapter2-demo"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "demo-vm"
  resource_group_name   = "rg-chapter2-demo"
  location              = "East US"
  size                  = "Standard_B1s"
  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_username        = "azureuser"
  admin_password        = "P@ssw0rd1234!"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}