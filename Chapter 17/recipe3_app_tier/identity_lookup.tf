############################################################
# identity_lookup.tf
# Purpose: Make the UAMI ID robust. If a literal ID is given,
#          fix casing for '/resourceGroups/'. Otherwise, look it
#          up by name and resource group.
############################################################

# Always available. Will be used only when var.uami_id is empty.
data "azurerm_user_assigned_identity" "app_uami" {
  name                = var.uami_name
  resource_group_name = var.uami_rg_name
}

# Sanitize common casing mistake from Azure CLI output
locals {
  uami_id_sanitized = var.uami_id != "" ? replace(var.uami_id, "/resourcegroups/", "/resourceGroups/") : ""
  uami_id_effective = var.uami_id != "" ? local.uami_id_sanitized : data.azurerm_user_assigned_identity.app_uami.id
}
