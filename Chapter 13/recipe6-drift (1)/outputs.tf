############################################
# outputs.tf
############################################
output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Resource group name for drift demo"
}

output "storage_account_name" {
  value       = azurerm_storage_account.sa.name
  description = "Storage account being used to demonstrate drift"
}

output "expected_tags" {
  value       = var.tags
  description = "Tags we expect Terraform to keep enforcing"
}
