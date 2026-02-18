# NIC without public IP
resource "azurerm_network_interface" "nic" {
  name                = "${var.resource_prefix}-nic"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.default_tags

  ip_configuration {
    name                          = "ipcfg"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    # No public_ip_address_id
  }
}

# Linux VM with system assigned identity
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.resource_prefix}-vm"
  location            = var.location
  resource_group_name = var.rg_name
  size                = "Standard_B1ms"
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]
  tags                  = var.default_tags

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  # Cloud-init script retrieves secret via MSI token and Key Vault REST API.
  # Only the secret URI is used. The secret value never appears in Terraform state.
  custom_data = base64encode(templatefile("${path.module}/templates/cloudinit.tpl", {
    secret_uri     = var.secret_uri
    key_vault_name = var.key_vault_name
  }))

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
