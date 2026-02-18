###############################################################
# Storage Transfer Service: Azure Blob  →  Google Cloud Storage
# Purpose: Copy raw training data from Azure (source container)
#          into a GCS bucket (processed data sink).
#
# Prereqs:
# - Azure Storage Account + private container "raw-data"
# - SAS token (container-level) with at least List + Read
# - GCS destination bucket already created
###############################################################

# NOTE: Provide var.azure_container_sas_token beginning with '?sv='
#       and scoped to the 'raw-data' container (List/Read perms).

resource "google_storage_transfer_job" "azure_to_gcs" {
  description = "Copy raw data from Azure Blob to GCS for training"
  project     = var.gcp_project
  status      = "ENABLED" # Job will be active once created

  transfer_spec {
    #############################################################
    # Source: Azure Blob container
    #############################################################
    azure_blob_storage_data_source {
      storage_account = azurerm_storage_account.st.name    # Azure Storage Account name
      container       = azurerm_storage_container.raw.name # Source container (e.g., raw-data)

      azure_credentials {
        sas_token = var.azure_container_sas_token # Container SAS (starts with '?sv=')
        # Minimum permissions: List + Read on container and blobs
        # TIP: Keep expiry short for security; rotate regularly.
      }
    }

    #############################################################
    # Sink: GCS bucket
    #############################################################
    gcs_data_sink {
      bucket_name = google_storage_bucket.processed.name # Destination bucket in GCS
    }

    #############################################################
    # Options: overwrite behavior, scheduling, etc.
    #############################################################
    transfer_options {
      overwrite_objects_already_existing_in_sink = true # Replace existing objects in GCS
      # Other options to consider:
      # delete_objects_from_source_after_transfer   = false
      # delete_objects_unique_in_sink               = false
      # metadata_options { symlink    = "SYMLINK_SKIP"
      #                    acl        = "ACL_PRESERVE"
      #                    storage_class = "NO_CHANGE" }
    }

    # By default this runs once immediately after creation.
    # For recurring schedules, uncomment and adjust:
    # schedule {
    #   schedule_start_date { year = 2025 month = 08 day = 27 }
    #   start_time_of_day   { hours = 02 minutes = 00 seconds = 00 } # 02:00 region time
    #   repeat_interval     = "86400s"  # daily
    # }
  }
}
