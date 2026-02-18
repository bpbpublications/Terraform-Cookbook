output "secondary_sql_server_name" {
  value = azurerm_mssql_server.secondary_sql.name
}

output "secondary_sql_private_endpoint_id" {
  value = azurerm_private_endpoint.secondary_sql_pe.id
}

output "failover_group_name" {
  value = azurerm_mssql_failover_group.fog.name
}

# The listener endpoint clients should use for writes
# (suffix is .database.windows.net and will CNAME to the current primary)
output "failover_group_listener" {
  value = "${azurerm_mssql_failover_group.fog.name}.database.windows.net"
}

# Useful for validation
output "primary_sql_server_name" {
  value = data.azurerm_mssql_server.primary.name
}
