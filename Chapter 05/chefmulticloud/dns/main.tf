resource "azurerm_dns_zone" "multi_dns" {
  name                = "multicloud.example.com"
  resource_group_name = azurerm_resource_group.azure_rg.name
}

resource "azurerm_dns_a_record" "app_record" {
  name                = "app"
  zone_name           = azurerm_dns_zone.multi_dns.name
  resource_group_name = azurerm_resource_group.azure_rg.name
  ttl                 = 60
  records             = [
    azurerm_public_ip.azure_lb_ip.ip_address,
    google_compute_address.gcp_lb_ip.address
  ]
}
