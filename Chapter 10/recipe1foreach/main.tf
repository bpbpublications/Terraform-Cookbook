# -------------------------------------------------------------------------
# Generate a single random suffix used by all storage accounts in this run.
# -------------------------------------------------------------------------
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  lower   = true
  number  = true
  special = false
}

# Supporting resource group to contain all storage accounts
resource "azurerm_resource_group" "rg" {
  name     = "rg-ch10-r1"
  location = "UK South"
}

# -------------------------------------------------------------------------
# Create one storage account per entry in var.storage_accounts. The final
# account name is the logical key plus the random suffix, ensuring global
# uniqueness and avoiding name‑collision errors.
# -------------------------------------------------------------------------
resource "azurerm_storage_account" "sa" {
  for_each = var.storage_accounts            # Iterate over the map

  name                     = "${each.key}${random_string.suffix.result}"
  location                 = each.value.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = each.value.tier
  account_replication_type = "LRS"          # Locally redundant storage
}