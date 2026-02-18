# Create an Azure Resource Group to hold all the infrastructure
resource "azurerm_resource_group" "rg" {
  name     = "ch6-r3-rg"     # Name of the resource group
  location = var.region      # Deployment region (e.g., eastus)
}

# Create a static Public IP address to associate with the Load Balancer frontend
resource "azurerm_public_ip" "pip" {
  name                = "lb-pip"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

# Create the Basic Load Balancer with a frontend IP config
resource "azurerm_lb" "lb" {
  name                = "web-lb"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"

  frontend_ip_configuration {
    name                 = "lb-frontend"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

# Define a backend address pool (VMs will be added here later)
resource "azurerm_lb_backend_address_pool" "pool" {
  name            = "lb-pool"
  loadbalancer_id = azurerm_lb.lb.id
}

# Define a health probe to check if backend VMs are healthy on port 80
resource "azurerm_lb_probe" "probe" {
  name            = "http-probe"
  loadbalancer_id = azurerm_lb.lb.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

# Create a Load Balancer rule to route traffic from frontend to backend
resource "azurerm_lb_rule" "rule" {
  name                           = "http"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lb-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.pool.id]  # List of backend pool IDs
  probe_id                       = azurerm_lb_probe.probe.id
}
