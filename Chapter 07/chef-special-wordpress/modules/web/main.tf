resource "azurerm_linux_virtual_machine_scale_set" "webscale" {
  name                = "wordpress-scale"
  location            = var.region
  resource_group_name = var.rg_name
  sku                 = "Standard_B1s"
  instances           = 2
  admin_username      = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key_path)
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "webscale-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      subnet_id = var.subnet_id
      primary   = true
    }
  }

  custom_data = filebase64("${path.module}/cloud-init-wordpress.sh")
}