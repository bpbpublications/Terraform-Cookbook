# Public IP address for the frontend of the Load Balancer
resource "azurerm_public_ip" "lb_public_ip" {
  name                = "web-lb-pip"
  location            = var.region
  resource_group_name = var.rg_name
  allocation_method   = "Static"       # Required for Standard SKU
  sku                 = "Standard"
}

# Azure Load Balancer for the web tier
resource "azurerm_lb" "web_lb" {
  name                = "web-loadbalancer"
  location            = var.region
  resource_group_name = var.rg_name
  sku                 = "Standard"     # Enables zone redundancy and HA

  # Frontend configuration uses the public IP created above
  frontend_ip_configuration {
    name                 = "web-frontend"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

# Backend pool to group the web VMs behind the load balancer
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name            = "web-backend-pool"
  loadbalancer_id = azurerm_lb.web_lb.id
}

# Health probe to monitor the availability of web VMs on port 80
resource "azurerm_lb_probe" "http_probe" {
  name                = "http-probe"
  loadbalancer_id     = azurerm_lb.web_lb.id
  protocol            = "Http"
  port                = 80
  request_path        = "/"               # Root path to probe
  interval_in_seconds = 15               # Probe interval
  number_of_probes    = 2                # Fail threshold
}

# Load balancing rule to forward HTTP traffic to backend web VMs
resource "azurerm_lb_rule" "http_rule" {
  name                            = "http-rule"
  loadbalancer_id                 = azurerm_lb.web_lb.id
  protocol                        = "Tcp"
  frontend_port                   = 80      # Public HTTP port
  backend_port                    = 80      # Port on VM
  frontend_ip_configuration_name  = "web-frontend"
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                        = azurerm_lb_probe.http_probe.id
}

# Associate each web VM NIC to the backend pool of the load balancer
resource "azurerm_network_interface_backend_address_pool_association" "web_pool_assoc" {
  for_each                = { for idx, nic_id in var.web_vm_nics : idx => nic_id }
  network_interface_id    = each.value
  ip_configuration_name   = "internal"      # Must match NIC config block
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}

# Dedicated public IP for the VPN Gateway (separate from the Load Balancer)
resource "azurerm_public_ip" "vpn_pip" {
  name                = "vpn-gw-pip"
  location            = var.region
  resource_group_name = var.rg_name
  allocation_method   = "Static"       # Required for VPN Gateway
  sku                 = "Standard"
}

# Placeholder for future VPN Gateway setup, configured with the VPN PIP
resource "azurerm_virtual_network_gateway" "vpn_gateway_placeholder" {
  name                = "vpn-gateway-placeholder"
  location            = var.region
  resource_group_name = var.rg_name
  type                = "Vpn"                   # Required type
  vpn_type            = "RouteBased"            # Most common configuration
  sku                 = "VpnGw1"                # Smallest available SKU

  ip_configuration {
    name                          = "vpngw-config"
    subnet_id                     = var.gateway_subnet_id           # Subnet must be named "GatewaySubnet"
    public_ip_address_id          = azurerm_public_ip.vpn_pip.id    # Uses dedicated PIP
    private_ip_address_allocation = "Dynamic"
  }
}
