resource "azurerm_public_ip" "lb_ip" {
  name                = "lb-ip"
  location            = var.region
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_lb" "web_lb" {
  name                = "web-lb"
  location            = var.region
  resource_group_name = var.rg_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "web-fe"
    public_ip_address_id = azurerm_public_ip.lb_ip.id
  }

}
