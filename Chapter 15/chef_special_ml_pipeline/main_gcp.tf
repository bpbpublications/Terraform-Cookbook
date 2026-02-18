###############################################################
# Random suffix to ensure globally-unique names
###############################################################
resource "random_string" "g_suffix" {
  length  = 6
  upper   = false
  special = false
}

###############################################################
# Storage bucket for processed data / training inputs
# - Uniform bucket-level access enforces IAM-only permissions
# - force_destroy lets Terraform delete non-empty buckets (lab-friendly)
###############################################################
resource "google_storage_bucket" "processed" {
  name                        = "ml-processed-${random_string.g_suffix.result}-${var.gcp_project}" # must be globally unique
  location                    = var.gcp_region
  force_destroy               = true
  uniform_bucket_level_access = true
}

###############################################################
# GPU Training VM (Compute Engine) with a single T4
# Notes:
# - Requires GPU quota in the chosen zone (e.g., us-central1-a)
# - Requires the Compute Engine API to be enabled
# - Debian 12 base image; switch to DLVM images if you want preinstalled frameworks
###############################################################
resource "google_compute_instance" "gpu_trainer" {
  name         = "trainer-${random_string.g_suffix.result}"
  machine_type = "n1-standard-4"       # 4 vCPU, 15 GB RAM (sized reasonably for a single T4)
  zone         = "${var.gcp_region}-a" # choose a zone that actually offers T4 capacity

  # Boot disk with Debian 12 (stable default)
  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
      # Alternative (preinstalled ML stacks):
      # image = "projects/deeplearning-platform-release/global/images/family/common-cpu"
    }
  }

  # Basic networking (default VPC) with ephemeral public IP
  network_interface {
    network = "default"
    access_config {} # creates an external IP; omit for private-only instances
  }

  # Attach a T4 GPU (1 unit). Change to "nvidia-tesla-t4" count > 1 as needed.
  guest_accelerator {
    type  = "nvidia-tesla-t4"
    count = 1
  }

  #################################################################
  # Startup script:
  # - Installs build tools and NVIDIA GPU driver (official helper)
  # - Writes the processed bucket URL into /var/tmp/train.log
  #################################################################
  metadata_startup_script = <<-EOT
    #!/usr/bin/env bash
    set -euxo pipefail

    # Base packages
    apt-get update
    apt-get install -y build-essential dkms curl python3-pip

    # NVIDIA driver installation using Google's helper script
    # (reboots are handled if required; check serial console logs if debugging)
    curl -fsSL https://raw.githubusercontent.com/GoogleCloudPlatform/compute-gpu-installation/main/install_gpu_driver.sh | bash

    # Simple verification / breadcrumb
    echo "Processed data bucket: gs://${google_storage_bucket.processed.name}" > /var/tmp/train.log
  EOT

  #################################################################
  # Scheduling requirements for GPU VMs:
  # - on_host_maintenance must be TERMINATE
  # - automatic_restart often disabled for training experiments
  #################################################################
  scheduling {
    on_host_maintenance = "TERMINATE"
    automatic_restart   = false
  }

  #################################################################
  # Service account + scopes:
  # - cloud-platform scope grants broad API access (simple for labs)
  # - In production, prefer least-privilege IAM roles on the SA
  #################################################################
  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  # Optional: tags to bind firewall rules (e.g., "ssh", "jupyter")
  # tags = ["gpu-trainer"]
}
