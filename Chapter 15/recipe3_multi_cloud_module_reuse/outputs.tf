###############################################################
# Outputs for Multi-Cloud Deployment
# Exposes the public endpoints of the web servers created
# in both Azure and GCP modules.
###############################################################

# Output the public IP address of the Azure VM
output "azure_public_ip" {
  value = module.web_azure.public_endpoint
  # The "public_endpoint" is an output exposed by the web_azure module
  # which typically maps to the Azure Public IP resource (azurerm_public_ip)
}

# Output the NAT IP address of the GCP VM
output "gcp_nat_ip" {
  value = module.web_gcp.public_endpoint
  # The "public_endpoint" is an output exposed by the web_gcp module
  # which maps to the ephemeral public IP (NAT IP) assigned by GCP
}
