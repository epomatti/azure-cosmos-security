output "id" {
  value = azurerm_key_vault.default.id
}

output "vault_uri" {
  value = azurerm_key_vault.default.vault_uri
}

output "keyvault_key_id" {
  value = azurerm_key_vault_key.generated.id
}

output "keyvault_key_resource_versionless_id" {
  value = azurerm_key_vault_key.generated.resource_versionless_id
}

output "keyvault_key_versionless_id" {
  value = azurerm_key_vault_key.generated.versionless_id
}
