#################
# FRONTEND VNET #
#################
module "Frontend-Networking" {
  source = "./modules/networking"

  rg_name            = azurerm_resource_group.resource-group.name
  vnet_name          = var.frontend_vnet_name
  vnet_address_space = var.frontend_vnet_address_space
  subnets            = var.frontend_subnets

  tags = var.tags
}

################
# BACKEND VNET #
################
module "Backend-Networking" {
  source = "./modules/networking"

  rg_name            = azurerm_resource_group.resource-group.name
  vnet_name          = var.backend_vnet_name
  vnet_address_space = var.backend_vnet_address_space
  subnets            = var.backend_subnets

  tags = var.tags
}

################
# VNET PEERING #
################
resource "azurerm_virtual_network_peering" "frontend_to_backend" {
  name                      = "frontend-to-backend"
  resource_group_name       = azurerm_resource_group.resource-group.name
  virtual_network_name      = module.Frontend-Networking.vnet_name
  remote_virtual_network_id = module.Backend-Networking.vnet_id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
}
resource "azurerm_virtual_network_peering" "backend_to_frontend" {
  name                      = "backend-to-frontend"
  resource_group_name       = azurerm_resource_group.resource-group.name
  virtual_network_name      = module.Backend-Networking.vnet_name
  remote_virtual_network_id = module.Frontend-Networking.vnet_id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
}

####################
# PRIVATE DNS ZONE #
####################
resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.resource-group.name

  tags = var.tags
}
resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.resource-group.name

  tags = var.tags
}

##########################
# PRIVATE DNS ZONE LINKS #
##########################
resource "azurerm_private_dns_zone_virtual_network_link" "sql_frontend" {
  name                  = "sql-dns-frontend-link"
  resource_group_name   = azurerm_resource_group.resource-group.name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = module.Frontend-Networking.vnet_id
  registration_enabled  = false
}
resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_frontend" {
  name                  = "kv-dns-frontend-link"
  resource_group_name   = azurerm_resource_group.resource-group.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = module.Frontend-Networking.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_backend" {
  name                  = "sql-dns-backend-link"
  resource_group_name   = azurerm_resource_group.resource-group.name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = module.Backend-Networking.vnet_id
  registration_enabled  = false
}
resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_backend" {
  name                  = "kv-dns-backend-link"
  resource_group_name   = azurerm_resource_group.resource-group.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = module.Backend-Networking.vnet_id
  registration_enabled  = false
}

#####################
# PRIVATE ENDPOINTS #
#####################
resource "azurerm_private_endpoint" "keyvault" {
  name                = "${module.KeyVault.kv_name}-pe"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
  subnet_id           = module.Backend-Networking.subnet_ids["mgmt_subnet"]

  private_service_connection {
    name                           = "${module.KeyVault.kv_name}-psc"
    private_connection_resource_id = module.KeyVault.kv_id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
  private_dns_zone_group {
    name                 = "kv-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.keyvault.id]
  }

  tags = var.tags
} 
resource "azurerm_private_endpoint" "sql" {
  name                = "${azurerm_mssql_server.sql-server.name}-pe"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
  subnet_id           = module.Backend-Networking.subnet_ids["backend_subnet"]

  private_service_connection {
    name                           = "${azurerm_mssql_server.sql-server.name}-psc"
    private_connection_resource_id = azurerm_mssql_server.sql-server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
  private_dns_zone_group {
    name                 = "sql-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql.id]
  }

  tags = var.tags
}


##########################
# APP SERVICE CONNECTION #
########################## 
resource "azurerm_app_service_virtual_network_swift_connection" "appservice_vnet_integration" {
  app_service_id = azurerm_linux_web_app.linux-app.id
  subnet_id      = module.Frontend-Networking.subnet_ids["frontend_subnet"]
}

#####################
# APP GATEWAY ITEMS #
#####################
resource "azurerm_public_ip" "pub_ip" {
  name                = "${var.appgw_name}-pip"
  resource_group_name = azurerm_resource_group.resource-group.name
  location            = azurerm_resource_group.resource-group.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_application_gateway" "appgw" {
  name                = var.appgw_name
  resource_group_name = azurerm_resource_group.resource-group.name
  location            = azurerm_resource_group.resource-group.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = module.Frontend-Networking.subnet_ids["gatewaySubnet"]
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.pub_ip.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  backend_address_pool {
    name  = "app-service-pool"
    fqdns = [azurerm_linux_web_app.linux-app.default_hostname]
  }

  backend_http_settings {
    name                                = "http-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "app-service-pool"
    backend_http_settings_name = "http-settings"
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

  tags = var.tags
}

###########################
# NETWORK SECURITY GROUPS #
###########################
resource "azurerm_network_security_group" "appgw_nsg" {
  for_each            = var.network_security_groups
  name                = each.key
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name

  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
  tags = var.tags
}
resource "azurerm_subnet_network_security_group_association" "associations" {
  for_each = var.nsg_subnet_associations

  subnet_id = (
    each.value.vnet_module == "frontend"
    ? module.Frontend-Networking.subnet_ids[each.value.subnet_key]
    : module.Backend-Networking.subnet_ids[each.value.subnet_key]
  )
  network_security_group_id = azurerm_network_security_group.nsg[each.value.nsg_key].id
}