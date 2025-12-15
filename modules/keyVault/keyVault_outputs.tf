#Key Vault Outputs
output "kv_name" {
  value = azurerm_key_vault.kv.name
}
output "kv_id" {
  value = azurerm_key_vault.kv.id
}