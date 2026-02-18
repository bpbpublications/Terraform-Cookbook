###############################################################
# Outputs
###############################################################

# Name of the Azure Blob container
# This container holds the raw data that will be transferred
# into Google Cloud Storage for training workflows.
output "azure_blob_container" {
  value       = azurerm_storage_container.raw.name
  description = "Azure container holding raw data"
}

# Name of the GCS bucket where processed data is stored
# This is the sink for the Storage Transfer Service job.
# Training scripts and VMs should read inputs from here.
output "gcs_processed_bucket" {
  value       = google_storage_bucket.processed.name
  description = "GCS bucket where data is transferred"
}

# Name of the GPU-enabled Compute Engine VM
# Used to run training workloads (with NVIDIA T4 accelerator).
# The startup script logs the processed bucket path under /var/tmp/train.log.
output "trainer_vm_name" {
  value       = google_compute_instance.gpu_trainer.name
  description = "Compute Engine VM for training"
}
