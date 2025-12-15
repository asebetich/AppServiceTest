#VNET Outputs
output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}
output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

#Subnet Outputs
output "subnet_names" {
  value = [for s in azurerm_subnet.subnet : s.name]
}
output "subnet_ids" {
  value = { for s in azurerm_subnet.subnet : s.name => s.id }
}