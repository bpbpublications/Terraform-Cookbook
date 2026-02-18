# Create a new resource group for all backup-related resources
resource "azurerm_resource_group" "rg" {
  name     = "ch7-r6-rg"      # Name of the resource group
  location = var.region       # Azure region (e.g., uksouth)
}

# Generate a random 4-character suffix to ensure the vault name is globally unique
resource "random_string" "vault_suffix" {
  length  = 4                 # Total number of characters
  upper   = false             # Do not include uppercase letters
  number  = false             # Do not include numbers
  special = false             # Do not include special characters
}

# Provision a Recovery Services Vault to hold backups and policies
resource "azurerm_recovery_services_vault" "vault" {
  name                          = "ch7vault${random_string.vault_suffix.result}"  # Unique vault name
  location                      = var.region                                     # Same region as RG
  resource_group_name           = azurerm_resource_group.rg.name                 # Link to the RG
  sku                           = "Standard"                                      # Vault SKU (Standard or Basic)
  storage_mode_type             = "LocallyRedundant"                              # Storage redundancy option
  public_network_access_enabled = true                                            # Allow portal/API access over internet
  soft_delete_enabled           = true                                            # Retain deleted backups for safety
}

# Define a daily backup policy for Azure VMs
resource "azurerm_backup_policy_vm" "vm_policy" {
  name                = "dailybackup"                                 # Policy identifier
  resource_group_name = azurerm_resource_group.rg.name               # Vault RG
  recovery_vault_name = azurerm_recovery_services_vault.vault.name   # Vault to attach policy
  policy_type         = "V1"                                          # Policy schema version
  timezone            = "UTC"                                         # Schedule timezone

  # Schedule block: take a snapshot once per day at 23:00 UTC
  backup {
    frequency = "Daily"    # Frequency of backups (Daily or Hourly)
    time      = "23:00"    # Local time (in the specified timezone)
  }

  # Retain each daily backup for 7 days
  retention_daily {
    count = 7              # Number of days to keep each snapshot
  }
}

# Register an existing VM with the vault and policy for protection
resource "azurerm_backup_protected_vm" "vm_protect" {
  resource_group_name = azurerm_resource_group.rg.name               # RG containing the VM
  recovery_vault_name = azurerm_recovery_services_vault.vault.name   # Vault that will protect the VM
  source_vm_id        = var.vm_id                                    # Resource ID of the VM to back up
  backup_policy_id    = azurerm_backup_policy_vm.vm_policy.id       # ID of the backup policy to apply
}

# Output the vault name so it can be referenced after apply
output "recovery_vault_name" {
  value = azurerm_recovery_services_vault.vault.name
}

# Output the backup policy name for easy verification
output "backup_policy_name" {
  value = azurerm_backup_policy_vm.vm_policy.name
}
