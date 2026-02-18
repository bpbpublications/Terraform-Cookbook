############################################################
# outputs.tf
# Purpose: Expose endpoints and IDs for later recipes.
############################################################

output "sql_server_name" {
  description = "SQL logical server name"
  value       = azurerm_mssql_server.sql.name
}

output "sql_database_name" {
  description = "SQL database name"
  value       = azurerm_mssql_database.db.name
}

output "sql_fqdn" {
  description = "SQL server fully qualified domain name"
  value       = "${azurerm_mssql_server.sql.name}.database.windows.net"
}

output "sql_private_endpoint_id" {
  description = "Resource ID of the SQL private endpoint (if created)"
  value       = try(azurerm_private_endpoint.sql_pe[0].id, null)
}
