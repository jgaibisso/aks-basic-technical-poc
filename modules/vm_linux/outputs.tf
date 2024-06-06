output "id" {
  value = try(azurerm_linux_virtual_machine.vm.id)
}

output "nic_id" {
  value = try(azurerm_network_interface.nic.id)
}
