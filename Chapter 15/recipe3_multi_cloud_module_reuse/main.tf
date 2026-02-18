###############################################################
# Local values and Multi-Cloud Module Calls (Azure + GCP)
# Demonstrates how the same web_server module can be reused
# for both Azure and GCP deployments with proper inputs.
###############################################################

# Load SSH public key content from a file path provided as variable
locals {
  ssh_public_key = file(var.ssh_public_key_path)
}

# Deploy the web_server module on Azure
module "web_azure" {
  source         = "./modules/web_server"  # Path to reusable module
  cloud          = "azure"                 # Tell the module we are targeting Azure
  name           = "websrv"                # Common resource name prefix
  az_location    = var.az_location         # Azure location/region
  ssh_public_key = local.ssh_public_key    # Inject loaded SSH key

  # Explicit provider mapping ensures the right provider instance is used
  providers = {
    azurerm = azurerm.az   # Use aliased Azure provider
    google  = google.gcp   # Pass Google provider (even if unused in this run)
  }
}

# Deploy the web_server module on GCP
module "web_gcp" {
  source         = "./modules/web_server"  # Same module reused for GCP
  cloud          = "gcp"                   # Tell the module we are targeting GCP
  name           = "websrv"                # Same name prefix for consistency
  gcp_region     = var.gcp_region          # GCP region
  ssh_public_key = local.ssh_public_key    # Inject loaded SSH key

  # Explicit provider mapping ensures the right provider instance is used
  providers = {
    azurerm = azurerm.az   # Pass Azure provider (even if unused in this run)
    google  = google.gcp   # Use aliased Google provider
  }
}
