# Resource Group: Logical container to hold all DNS-related resources
resource "azurerm_resource_group" "rg" {
  name     = "ch6-r4-rg"
  location = var.region
}

# Public IP: Creates a static public IP address that can be mapped to a DNS record
resource "azurerm_public_ip" "ip" {
  name                = "dns-ip"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"  # Ensures the IP doesn't change
}

# DNS Zone: Registers a DNS zone for the domain (e.g., example.com)
resource "azurerm_dns_zone" "zone" {
  name                = "example.com"  # Replace with your actual domain
  resource_group_name = azurerm_resource_group.rg.name
}

# A Record: Maps a subdomain (e.g., www.example.com) to the public IP
resource "azurerm_dns_a_record" "arec" {
  name                = "www"  # This creates 'www.example.com'
  zone_name           = azurerm_dns_zone.zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300  # Time-to-live in seconds for DNS caching
  records             = [azurerm_public_ip.ip.ip_address]  # Assigns the public IP to the A record
}
