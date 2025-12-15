#Import existing Resource Group
data "azurerm_resource_group" "resource-group" {
  name = var.rg_name
}

#Creates the Azure Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = data.azurerm_resource_group.resource-group.location
  resource_group_name = data.azurerm_resource_group.resource-group.name
  address_space       = var.vnet_address_space

  tags       = var.tags
  depends_on = [data.azurerm_resource_group.resource-group]
}

#New approach:
resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  resource_group_name  = data.azurerm_resource_group.resource-group.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  name             = each.value.subnet_name
  address_prefixes = each.value.address_prefixes

  service_endpoints                             = each.value.service_endpoints
  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = try(each.value.private_link_service_network_policies_enabled, true)
  dynamic "delegation" {
    for_each = try(each.value.delegation, [])
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = try(delegation.value.service_delegation.actions, [])
      }
    }
  }
}