output "existing_rg_id" {
  description = "The full Azure ID of the existing Resource Group."
  value       = data.azurerm_resource_group.existing.id
}

output "storage_account_endpoint" {
  value = azurerm_storage_account.files.primary_blob_endpoint
}
