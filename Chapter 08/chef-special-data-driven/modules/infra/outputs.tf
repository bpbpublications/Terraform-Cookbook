output "subnet_ids" {
  value = { for k, v in azurerm_subnet.subnets : k => v.id }
}