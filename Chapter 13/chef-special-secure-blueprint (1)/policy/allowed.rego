package policy.allowed

import future.keywords.if
import future.keywords.in
import future.keywords.contains

import data.terraform.common

allowed_types := {
    "azurerm_resource_group",
    "azurerm_storage_account",
    "azurerm_virtual_network",
    "azurerm_subnet",
    "azurerm_network_security_group",
}

deny contains msg if {
    rc := common.resource_changes[_]
    common.is_create_or_update_rc(rc)
    not rc.type in allowed_types
    msg := sprintf("Resource type %s is not allowed", [rc.type])
}