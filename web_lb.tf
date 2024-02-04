resource "azurerm_public_ip" "web_lb" {
  name                = "web-ip"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "web" {
  name                = "web-lb"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "web-lb-ip"
    public_ip_address_id = azurerm_public_ip.web_lb.id
    gateway_load_balancer_frontend_ip_configuration_id = azurerm_lb.fw.frontend_ip_configuration[0].id
  }

}

resource "azurerm_lb_backend_address_pool" "web" {
  loadbalancer_id = azurerm_lb.web.id
  name            = "web-servers"
}

# resource "azurerm_lb_backend_address_pool_address" "web" {
#   name                    = "web-lb-pool"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.web.id
#   virtual_network_id      = azurerm_virtual_network.web.id
#   ip_address              = azurerm_network_interface.web.ip_configuration[0].private_ip_address
# }

resource "azurerm_network_interface_backend_address_pool_association" "web" {
  network_interface_id    = azurerm_network_interface.web.id
  ip_configuration_name   = "web-nic-ip"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web.id
}

resource "azurerm_lb_probe" "http_probe" {
  loadbalancer_id = azurerm_lb.web.id
  name            = "http-probe"
  protocol        = "Http"
  request_path    = "/"
  port            = 80
}

resource "azurerm_lb_rule" "web" {
  loadbalancer_id                = azurerm_lb.web.id
  name                           = "HTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "web-lb-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web.id]
  probe_id                       = azurerm_lb_probe.http_probe.id
  disable_outbound_snat = true
}

resource "azurerm_lb_outbound_rule" "web" {
  name                    = "web-outbound"
  loadbalancer_id         = azurerm_lb.web.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web.id
  allocated_outbound_ports =512

  frontend_ip_configuration {
    name = "web-lb-ip"
  }
}

#resource "azurerm_dns_a_record" "web" {
#  name                = "web"
#  zone_name           = "az.ciscodemo.net"
#  resource_group_name = "dns"
#  ttl                 = 5
#  records             = [azurerm_public_ip.web_lb.ip_address]
#}