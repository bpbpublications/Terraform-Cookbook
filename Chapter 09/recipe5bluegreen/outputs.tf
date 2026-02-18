output "application_gateway_public_ip" {
  description = "Public IP to access the active environment"
  value       = azurerm_public_ip.agw_ip.ip_address
}

output "active_environment" {
  description = "Current active environment (blue/green)"
  value       = var.env_prefix
}