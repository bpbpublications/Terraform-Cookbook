output "azure_vpn_public_ip" {
  value = azurerm_public_ip.vpn_pip.ip_address
}

output "gcp_vpn_public_ip" {
  value = google_compute_address.vpn_ip.address
}
