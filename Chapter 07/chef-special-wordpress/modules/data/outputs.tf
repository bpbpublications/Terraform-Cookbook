output "db_host" {
  value = azurerm_mysql_flexible_server.db.fqdn
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "storage_container_name" {
  value = azurerm_storage_container.media.name
}