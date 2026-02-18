###############################################################
# Google Cloud Run Service
# Deploys a containerized application to Cloud Run (fully managed)
###############################################################

resource "google_cloud_run_v2_service" "r4" {
  name     = "hello-r4"     # Name of the Cloud Run service
  location = var.gcp_region # Region where the service is deployed

  deletion_protection = false # Allow deletion during testing/demos (set true in prod)

  # Define the service template
  template {
    containers {
      image = var.gcp_container_image # Container image (Artifact Registry or Docker Hub)
      # Example default: "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
}

###############################################################
# Make the Cloud Run service publicly accessible
# Grants the "Cloud Run Invoker" role to all users
###############################################################

resource "google_cloud_run_v2_service_iam_member" "r4_public" {
  name     = google_cloud_run_v2_service.r4.name     # Service name reference
  location = google_cloud_run_v2_service.r4.location # Same region as service
  project  = google_cloud_run_v2_service.r4.project  # Same GCP project as service

  role   = "roles/run.invoker" # Role required to invoke Cloud Run
  member = "allUsers"          # Allow anyone with the URL to access
}
