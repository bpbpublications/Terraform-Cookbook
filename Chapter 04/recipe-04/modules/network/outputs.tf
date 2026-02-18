output "subnet_id" {
  description = "The ID of the created subnet"
  value       = azurerm_subnet.subnet.id
}