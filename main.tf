##############
# DATA CALLS #
##############
data "azurerm_client_config" "current" {}

##################
# RESOURCE GROUP #
##################
resource "azurerm_resource_group" "resource-group" {
  name     = var.rg_name
  location = var.location

  tags = var.tags
}

#############
# KEY VAULT #
#############
module "KeyVault" {
  source = "./modules/keyVault"

  rg_name        = azurerm_resource_group.resource-group.name
  key_vault_name = var.key_vault_name
  key_vault_sku  = "standard"
  tenant_id      = data.azurerm_client_config.current.tenant_id

  keyvault_access_policy = {
    linux-app-policy = { # Access policy for the Linux App Service
      tenant_id          = data.azurerm_client_config.current.tenant_id
      object_id          = azurerm_linux_web_app.linux-app.identity[0].principal_id
      secret_permissions = ["Get", "List"]
    }
  }

  tags = var.tags
}

#########################
# SQL SERVER & DATABASE #
#########################
resource "azurerm_mssql_server" "sql-server" {
  name                          = var.sql_server_name
  resource_group_name           = azurerm_resource_group.resource-group.name
  location                      = azurerm_resource_group.resource-group.location
  version                       = "12.0"
  administrator_login           = var.sql_admin_username
  administrator_login_password  = var.sql_admin_password
  public_network_access_enabled = false

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = data.azurerm_client_config.current.object_id
    tenant_id      = data.azurerm_client_config.current.tenant_id
  }  

  tags = var.tags
}
resource "azurerm_mssql_server_extended_auditing_policy" "sql-audit" {
  server_id = azurerm_mssql_server.sql-server.id
}
resource "azurerm_mssql_database" "sql-db" {
  name      = var.sql_database_name
  server_id = azurerm_mssql_server.sql-server.id
  sku_name  = "BC_Gen5_2" # Business Critical, Gen5, 2 vCores

  tags = var.tags

  lifecycle { # Prevent accidental deletion of the database
    prevent_destroy = true
  }
}

####################################
# APP SERVICE PLAN AND APP SERVICE #
####################################
resource "azurerm_service_plan" "asp" {
  name                   = var.asp_name
  resource_group_name    = azurerm_resource_group.resource-group.name
  location               = azurerm_resource_group.resource-group.location
  os_type                = "Linux" # <-- This
  sku_name               = "P1v3"  # one redundancy requirement
  zone_balancing_enabled = true    # HA across zones

  tags = var.tags
}

resource "azurerm_linux_web_app" "linux-app" {
  name                = var.linux_app_name
  resource_group_name = azurerm_resource_group.resource-group.name
  location            = azurerm_resource_group.resource-group.location
  service_plan_id     = azurerm_service_plan.asp.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    SQL_SERVER   = azurerm_mssql_server.sql-server.fully_qualified_domain_name
    SQL_DATABASE = azurerm_mssql_database.sql-db.name
  }
  tags = var.tags
}