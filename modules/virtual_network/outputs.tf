output "id" {
  value       = azurerm_virtual_network.vnet.id
  description = "id"
}

output "name" {
  value       = azurerm_virtual_network.vnet.name
  description = "name"
}

output "rg_name" {
  value       = azurerm_virtual_network.vnet.resource_group_name
  description = "rg name"
}
