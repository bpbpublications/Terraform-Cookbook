variable "zone" {
  type    = string
  default = "us-central1-a"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "<YOUR_GCP_PROJECT_ID>"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_instance" "vm" {
  name         = "ch5-r3-vm"
  machine_type = "e2-micro"
  zone         = var.zone  # we can pass zone as a variable or use provider default

  # Use the default VPC and subnet
  network_interface {
    network       = "default"
    access_config {}  # This automatically assigns an ephemeral public IP
  }

  # Boot disk image (Ubuntu 22.04 LTS from Ubuntu Cloud project)
  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
    }
  }

  # SSH key setup via metadata
  metadata = {
    ssh-keys = "terraform:${file("~/.ssh/id_rsa.pub")}"
  }

  tags = ["ssh"]  # Tag the instance, e.g., for firewall rules if needed
}