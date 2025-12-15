#Provider Configuration
variable "subscription_id" {
  description = "Azure Subscription ID value"
}
variable "tenant_id" {
  description = "Azure Tenant ID value"
}

#General Variables
variable "tags" {
  description = "The tags to associate with your resource(s)"
  type        = map(string)
}
variable "location" {
  description = "Azure location for resource deployment"
}

#Resource Group
variable "rg_name" {
  description = "Name of the Resource Group to create"
}

#Networking Module Frontend VNET
variable "frontend_vnet_name" {
  description = "Name of the VNET to create"
}
variable "frontend_vnet_address_space" {
  description = "Address space for the VNET"
}
variable "frontend_subnets" {
  description = "Subnets to create within the VNET"
  type = map(object({
    subnet_name      = string
    address_prefixes = list(string)
  }))
}

#Networking Module Backend VNET
variable "backend_vnet_name" {
  description = "Name of the VNET to create"
}
variable "backend_vnet_address_space" {
  description = "Address space for the VNET"
}
variable "backend_subnets" {
  description = "Subnets to create within the VNET"
  type = map(object({
    subnet_name      = string
    address_prefixes = list(string)
  }))
}

#App Service Variables
variable "asp_name" {
  description = "Name of the App Service Plan to create"
}
variable "linux_app_name" {
  description = "Name of the Linux App Service to create"
}

#Key Vault Variables
variable "key_vault_name" {
  description = "Name of the Key Vault to create"
}


# SQL Database Server Variables
variable "sql_server_name" {
  description = "Name of the SQL Server to create"
}
variable "sql_admin_username" {
  description = "SQL Server admin username"
  sensitive   = true
}
variable "sql_admin_password" {
  description = "SQL Server admin password"
  sensitive   = true
}
variable "sql_database_name" {
  description = "Name of the SQL Database to create"
}

# Application Gateway Variables
variable "appgw_name" {
  description = "Name of the Application Gateway to create"
}

# NSG Variables
variable "network_security_groups" {
  description = "Map of NSGs and their rules"
  type = map(object({
    rules = map(object({
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
}
variable "nsg_subnet_associations" {
  description = "Map of NSG to subnet associations"
  type = map(object({
    subnet_key  = string
    nsg_key     = string
    vnet_module = string
  }))
}