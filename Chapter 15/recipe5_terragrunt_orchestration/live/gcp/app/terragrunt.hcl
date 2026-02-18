terraform {
  source = "../../../modules/gcp-app"
}

# Generate the provider for Google
generate "provider" {
  path      = "provider.google.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}
EOF
}

# Remote state for GCP using the gcs backend
# The bucket must exist; enable Object Versioning for recovery
remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "your-gcs-terraform-state-bucket"
    prefix = "gcp/app"
  }
}
# GCS backend stores state in an existing bucket and supports locking.
# Google recommends enabling bucket versioning. :contentReference[oaicite:2]{index=2}

inputs = {
  gcp_region          = "us-central1"
  app_name            = "tg-app-gcp"
  gcp_container_image = "us-docker.pkg.dev/cloudrun/container/hello"
}
