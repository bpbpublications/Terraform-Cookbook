package policy.storage

import future.keywords.if
import future.keywords.contains

import data.terraform.common

deny contains msg if {
    rc := common.changes_of_type("azurerm_storage_account")[_]
    not object.get(rc.change.after, "enable_https_traffic_only", false)
    msg := sprintf("Storage account %s must have HTTPS traffic enabled", [rc.address])
}

deny contains msg if {
    rc := common.changes_of_type("azurerm_storage_account")[_]
    object.get(rc.change.after, "min_tls_version", "") != "TLS1_2"
    msg := sprintf("Storage account %s must use TLS 1.2", [rc.address])
}

deny contains msg if {
    rc := common.changes_of_type("azurerm_storage_account")[_]
    object.get(rc.change.after, "public_network_access_enabled", false)
    msg := sprintf("Storage account %s must disable public network access", [rc.address])
}

deny contains msg if {
    rc := common.changes_of_type("azurerm_storage_account")[_]
    queue_encryption := object.get(object.get(rc.change.after, "queue_properties", {}), "encryption", {})
    object.get(queue_encryption, "key_type", "") != "Service"
    msg := sprintf("Storage account %s queues must use Service-managed keys", [rc.address])
}