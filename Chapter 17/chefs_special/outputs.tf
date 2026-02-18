output "foundation_rg" {
  value = azurerm_resource_group.core.name
}

output "app_rg" {
  value = azurerm_resource_group.app.name
}

output "db_rg" {
  value = azurerm_resource_group.db.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}

output "load_balancer_ip" {
  value = azurerm_lb.ilb.frontend_ip_configuration[0].private_ip_address
}

output "vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.vmss.id
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sql.fully_qualified_domain_name
}

output "sql_private_endpoint" {
  value = azurerm_private_endpoint.sql_pe.id
}
