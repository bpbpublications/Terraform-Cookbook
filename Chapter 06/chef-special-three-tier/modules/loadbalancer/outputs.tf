output "load_balancer_ip" {
  description = "Public IP for the load balancer"
  value       = azurerm_public_ip.lb_public_ip.ip_address
}
