# Create Load balancer
resource "azurerm_lb" "lb" {
  name                = format("%s-lb", var.res_prefix)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = format("%s-lb-pip", var.res_prefix)
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb_cpnode_pool" {
  loadbalancer_id      = azurerm_lb.lb.id
  name                 = "cpnode-pool"
}

resource "azurerm_lb_backend_address_pool" "lb_node_pool" {
  loadbalancer_id      = azurerm_lb.lb.id
  name                 = "node-pool"
}

resource "azurerm_lb_probe" "lb_api_probe" {
  name                = format("%s-api", var.res_prefix)

  loadbalancer_id     = azurerm_lb.lb.id
  port                = 6443
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "lb_api_rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "kube-apiserver-lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = 6443
  backend_port                   = 443
  disable_outbound_snat          = true
  frontend_ip_configuration_name = azurerm_public_ip.lb_public_ip.name
  probe_id                       = azurerm_lb_probe.lb_api_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_cpnode_pool.id]
}
