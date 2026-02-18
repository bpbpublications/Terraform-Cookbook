###############################################################
# Outputs
###############################################################

# Show which Terraform workspace is currently active
# This controls which cloud resources are deployed.
output "active_workspace" {
  value       = terraform.workspace
  description = "Current workspace name"
}

# Output the Azure Resource Group name
# Only populated when the active workspace is "azure".
# If not in Azure workspace, returns null.
output "azure_resource_group" {
  value       = try(azurerm_resource_group.rg[0].name, null)
  description = "Azure Resource Group name when in the 'azure' workspace"
}

# Output the GCP Storage Bucket name
# Only populated when the active workspace is "gcp".
# If not in GCP workspace, returns null.
output "gcp_bucket_name" {
  value       = try(google_storage_bucket.bucket[0].name, null)
  description = "GCS bucket name when in the 'gcp' workspace"
}
