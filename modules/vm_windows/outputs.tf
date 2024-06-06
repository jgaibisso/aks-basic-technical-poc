output "id" {
  value = try(azurerm_windows_virtual_machine.vm[0].id, null)
}
