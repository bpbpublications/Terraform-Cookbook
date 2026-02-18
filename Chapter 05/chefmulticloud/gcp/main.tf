provider "google" {
  project = "<YOUR_GCP_PROJECT_ID>"
  region  = "us-central1"
}

# Reserve a static external IP for GCP Load Balancer
resource "google_compute_address" "gcp_lb_ip" {
  name   = "gcp-multi-lb-ip"
  region = "us-central1"
}

# Create two VM instances (web servers)
resource "google_compute_instance" "web" {
  count        = 2
  name         = "gcp-web-${count.index}"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  network_interface {
    network       = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    sed -i 's/Welcome to nginx!/Welcome from GCP instance ${HOSTNAME}/' /var/www/html/index.nginx-debian.html
    systemctl enable nginx --now
  EOT

  tags = ["gcp-web"]
}

# Health check for LB
resource "google_compute_http_health_check" "web_health" {
  name         = "gcp-web-health"
  request_path = "/"
  port         = 80
}

# Target pool for network load balancing
resource "google_compute_target_pool" "web_pool" {
  name         = "gcp-web-pool"
  health_checks = [google_compute_http_health_check.web_health.self_link]
  instances     = [for inst in google_compute_instance.web : inst.self_link]
}

# Forwarding rule (regional Network LB)
resource "google_compute_forwarding_rule" "web_lb" {
  name       = "gcp-multi-lb-rule"
  region     = "us-central1"
  target     = google_compute_target_pool.web_pool.self_link
  port_range = "80"
  ip_address = google_compute_address.gcp_lb_ip.address
}

# Firewall rule to allow LB access to port 80
resource "google_compute_firewall" "allow_web" {
  name    = "allow-web-lb"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["gcp-web"]
}