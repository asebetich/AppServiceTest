####################
# RESOURCE OUTPUTS #
####################
#Resource Group
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.resource-group.name
}
output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.resource-group.location
}

#Key Vault
output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = module.KeyVault.kv_id
}
output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.KeyVault.kv_name
}
output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.KeyVault.kv_uri
}

#SQL Server & Database
output "sql_server_id" {
  description = "ID of the SQL Server"
  value       = azurerm_mssql_server.sql-server.id
}
output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.sql-server.fully_qualified_domain_name
}
output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.sql-db.name
}
output "sql_database_id" {
  description = "ID of the SQL Database"
  value       = azurerm_mssql_database.sql-db.id
}

#App Service
output "app_service_id" {
  description = "ID of the App Service"
  value       = azurerm_linux_web_app.linux-app.id
}
output "app_service_hostname" {
  description = "Default hostname of the App Service"
  value       = azurerm_linux_web_app.linux-app.default_hostname
}
output "app_service_principal_id" {
  description = "Principal ID of the App Service Managed Identity"
  value       = azurerm_linux_web_app.linux-app.identity[0].principal_id
}
# App Service Plan
output "app_service_plan_id" {
  description = "ID of the App Service Plan"
  value       = azurerm_service_plan.asp.id
}

###################
# NETWORK OUTPUTS #
###################
#Frontend VNet
output "frontend_vnet_id" {
  description = "ID of the Frontend VNet"
  value       = module.Frontend-Networking.vnet_id
}
output "frontend_vnet_name" {
  description = "Name of the Frontend VNet"
  value       = module.Frontend-Networking.vnet_name
}
output "frontend_subnet_ids" {
  description = "Map of Frontend subnet names to IDs"
  value       = module.Frontend-Networking.subnet_ids
}

#Backend VNet
output "backend_vnet_id" {
  description = "ID of the Backend VNet"
  value       = module.Backend-Networking.vnet_id
}
output "backend_vnet_name" {
  description = "Name of the Backend VNet"
  value       = module.Backend-Networking.vnet_name
}
output "backend_subnet_ids" {
  description = "Map of Backend subnet names to IDs"
  value       = module.Backend-Networking.subnet_ids
}

#Private Endpoints
output "sql_private_endpoint_ip" {
  description = "Private IP address of the SQL Private Endpoint"
  value       = azurerm_private_endpoint.sql.ip_configuration[0].private_ip_address
}

output "keyvault_private_endpoint_ip" {
  description = "Private IP address of the Key Vault Private Endpoint"
  value       = azurerm_private_endpoint.keyvault.ip_configuration[0].private_ip_address
}

#Application Gateway
output "app_gateway_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}
output "app_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.pub_ip.ip_address
}

#NSGs
output "nsg_ids" {
  description = "Map of NSG names to IDs"
  value       = { for key, value in azurerm_network_security_group.nsg : key => value.id }
}