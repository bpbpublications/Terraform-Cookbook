# A list variable that holds the names of the environments we want VMs for
variable "vm_names" {
  type    = list(string)          # The variable is a list of strings
  default = ["dev", "qa", "prod"] # Three environment names
}

# Create one VM for each environment name above
resource "azurerm_linux_virtual_machine" "vm" {
  for_each = toset(var.vm_names)  # Iterate over the list (as a set) to produce dev, qa, prod keys

  name                = "${each.key}-vm"               # VM name becomes dev-vm, qa-vm, or prod-vm
  resource_group_name = azurerm_resource_group.rg.name  # Use the resource group created earlier
  location            = var.region                      # Deploy to the region supplied via variable
  size                = "Standard_B1s"                 # VM size (small for demo)
  admin_username      = "azureuser"                    # OS admin user

  # Disable password login and rely on SSH keys for security
  disable_password_authentication = true
}