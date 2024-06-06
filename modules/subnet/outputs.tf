output "name" {
  description = "Subnet name."
  value       = azurerm_subnet.snet.name
}

output "id" {
  description = "Subnet ID."
  value       = azurerm_subnet.snet.id
}

output "resource_group_name" {
  description = "Resource Group name in which the subnet is created in."
  value       = azurerm_subnet.snet.resource_group_name
}

output "virtual_network_name" {
  description = "The name of the virtual network in which the subnet is created in."
  value       = azurerm_subnet.snet.virtual_network_name
}

output "address_prefixes" {
  description = "The address prefixes for the subnet."
  value       = azurerm_subnet.snet.address_prefixes
}