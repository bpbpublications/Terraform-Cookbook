terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Create the GKE cluster with basic settings
resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.region

  initial_node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# Output kubeconfig-compatible cluster endpoint and credentials
output "gke_endpoint" {
  value = google_container_cluster.gke.endpoint
}

output "gke_name" {
  value = google_container_cluster.gke.name
}