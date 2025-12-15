#Import existing Resource Group
data "azurerm_resource_group" "resource-group" {
  name = var.rg_name
}

#Creates the Azure Key Vault
resource "azurerm_key_vault" "kv" {
  resource_group_name = data.azurerm_resource_group.resource-group.name
  location            = data.azurerm_resource_group.resource-group.location

  name                          = var.key_vault_name
  sku_name                      = var.key_vault_sku
  tenant_id                     = var.tenant_id
  public_network_access_enabled = false

  tags       = var.tags
  depends_on = [data.azurerm_resource_group.resource-group]
}

#Creates Key Vault Access Policies
resource "azurerm_key_vault_access_policy" "access-policy" {
  for_each     = var.keyvault_access_policy
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = each.value.tenant_id
  object_id    = each.value.object_id

  certificate_permissions = each.value.certificate_permissions
  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
}