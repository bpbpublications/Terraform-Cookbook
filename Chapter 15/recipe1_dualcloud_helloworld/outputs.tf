###############################################################
# Outputs: Public Endpoints for Azure and GCP VMs
###############################################################

# Azure VM Public IP Address
output "azure_public_ip" {
  value = azurerm_public_ip.pip.ip_address
  # This is the static public IP assigned to the Azure Linux VM.
  # Use this to connect via SSH: ssh <user>@<azure_public_ip>
}

# GCP VM NAT IP Address
output "gcp_instance_nat_ip" {
  value = google_compute_instance.vm_gcp.network_interface[0].access_config[0].nat_ip
  # This is the ephemeral external IP assigned to the GCP VM.
  # Use this to connect via SSH: ssh <user>@<gcp_instance_nat_ip>
}
