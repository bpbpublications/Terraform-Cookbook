###############################################################
# Outputs
###############################################################

# Output the Cloud Run service URL
output "cloud_run_url" {
  value = google_cloud_run_v2_service.svc.uri
  # Example: https://tg-app-gcp-xyz.a.run.app
  # Use this URL to access the deployed containerized application.
}
