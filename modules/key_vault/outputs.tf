output "id" {
  value       = try(azurerm_key_vault.kv.id, null)
  description = "KeyVault Id"
}

output "name" {
  value       = try(azurerm_key_vault.kv.name, null)
  description = "KeyVault Name"
}