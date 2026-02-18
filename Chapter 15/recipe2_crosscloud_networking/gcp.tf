resource "google_compute_network" "vpc" {
  name                    = "vpc-ch15-gcp"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "subnet-ch15-gcp"
  ip_cidr_range = var.gcp_subnet_cidr
  region        = var.gcp_region
  network       = google_compute_network.vpc.id
}

# Reserve an external IP for the Classic VPN gateway
resource "google_compute_address" "vpn_ip" {
  name   = "vpn-ip-ch15"
  region = var.gcp_region
}

# Classic VPN gateway
resource "google_compute_vpn_gateway" "target_gateway" {
  name    = "vpn-gw-ch15"
  region  = var.gcp_region
  network = google_compute_network.vpc.id
}

# Forwarding rules for ESP and IKE traffic to the gateway
resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  region      = var.gcp_region
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_ip.address
  target      = google_compute_vpn_gateway.target_gateway.self_link
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  region      = var.gcp_region
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_ip.address
  target      = google_compute_vpn_gateway.target_gateway.self_link
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  region      = var.gcp_region
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_ip.address
  target      = google_compute_vpn_gateway.target_gateway.self_link
}

# VPN tunnel to Azure public IP
resource "google_compute_vpn_tunnel" "tunnel" {
  name               = "tunnel-to-azure"
  region             = var.gcp_region
  target_vpn_gateway = google_compute_vpn_gateway.target_gateway.id
  peer_ip            = azurerm_public_ip.vpn_pip.ip_address
  shared_secret      = var.psk

  # Static, policy-based selectors keep the example simple
  local_traffic_selector  = [var.gcp_subnet_cidr]
  remote_traffic_selector = [var.az_subnet_cidr]

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500
  ]
}

# Route Azure subnet through the tunnel
resource "google_compute_route" "to_azure" {
  name                = "route-to-azure"
  network             = google_compute_network.vpc.name
  dest_range          = var.az_subnet_cidr
  priority            = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel.id
}
