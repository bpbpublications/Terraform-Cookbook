###############################################################
# Terraform Configuration for Deploying a Linux VM on GCP
# Includes firewall rule, VM setup, SSH key injection, and Nginx
###############################################################

# Specify the required provider and version
terraform {
  required_providers {
    google = { 
      source  = "hashicorp/google" # Google Cloud provider
      version = ">= 5.0"           # Require version 5.0 or higher
    }
  }
}

# Input variables
variable "name" { 
  type = string 
  # Resource name prefix (used across firewall, VM, etc.)
}

variable "gcp_region" { 
  type = string 
  # Region where resources will be deployed (e.g., us-central1)
}

variable "ssh_public_key" { 
  type = string 
  # SSH public key for VM access
}

# Firewall rule to allow inbound HTTP traffic on port 80
resource "google_compute_firewall" "allow_http" {
  name    = "fw-allow-http-${var.name}" # Unique firewall rule name
  network = "default"                   # Apply to default VPC network

  allow {
    protocol = "tcp"
    ports    = ["80"]                   # Allow only HTTP traffic
  }

  direction     = "INGRESS"             # Inbound rule
  source_ranges = ["0.0.0.0/0"]         # Allow traffic from anywhere
  target_tags   = ["web-${var.name}"]   # Apply to VMs with this tag
}

# Create a VM instance on GCP
resource "google_compute_instance" "vm" {
  name         = "vm-${var.name}-gcp"   # VM name
  machine_type = "e2-micro"             # Small instance type (free tier eligible)
  zone         = "${var.gcp_region}-a"  # Deploy in region's "a" zone
  tags         = ["web-${var.name}"]    # Match firewall rule by tag

  # Boot disk configuration with Ubuntu 22.04 LTS image
  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
    }
  }

  # Attach VM to the default network with a public IP
  network_interface {
    network = "default"
    access_config {} # Creates external IP address
  }

  # Inject SSH key into VM metadata for login
  metadata = {
    # Format: "username:ssh-rsa AAAAB3..."; Terraform variable supplies the key
    ssh-keys = "cookbook:${var.ssh_public_key}"
  }

  # Startup script to configure the VM with Nginx
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    echo "<h1>Hello from GCP</h1>" > /var/www/html/index.html
    systemctl enable nginx
    systemctl restart nginx
  EOT
}
