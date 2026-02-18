	resource "azurerm_public_ip" "web" {
	  name                = "ch3-r2-ip"
	  resource_group_name = azurerm_resource_group.rg.name
	  location            = var.region
	  allocation_method   = "Static"
	}
	
	output "web_ip" {
	  description = "Public IP for the web server"
	  value       = azurerm_public_ip.web.ip_address
	}
