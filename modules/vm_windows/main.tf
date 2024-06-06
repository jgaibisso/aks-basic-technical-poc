## --------------------------------------
##  LOCAL VARIABLES
## --------------------------------------

locals {
  tags        = var.tags
  format_disk = templatefile("${path.module}/FormatDisk.ps1", {})
}

## --------------------------------------
##  NETWORK INTERFACE (NIC)
## --------------------------------------

resource "azurerm_network_interface" "nic" {
  count = var.name == "" ? 0 : 1 # if name doesn't exist, count = 0 and skips

  name                = "nic-${var.name}"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "nic-config"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address            = var.private_ip_address
  }

  tags = local.tags
}

## --------------------------------------
##  VIRTUAL MACHINE
## --------------------------------------

resource "azurerm_windows_virtual_machine" "vm" {
  count = var.name == "" ? 0 : 1 # if name doesn't exist, count = 0 and skips

  name                = var.name
  admin_username      = var.admin_username
  admin_password      = random_password.password[0].result
  location            = var.location
  resource_group_name = var.rg_name
  size                = var.vm_size

  network_interface_ids = [azurerm_network_interface.nic[0].id]

  zone = var.zone

  os_disk {
    name                 = "osdisk-${var.name}"
    caching              = "ReadWrite"
    storage_account_type = var.os_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = "latest"
  }

  ##  Patch Managment
  patch_mode                                             = "AutomaticByPlatform"
  patch_assessment_mode                                  = "AutomaticByPlatform"
  bypass_platform_safety_checks_on_user_schedule_enabled = true

  dynamic "identity" {
    for_each = var.enable_azure_monitor_agent ? [1] : []

    content {
      type = "SystemAssigned"
    }
  }

  tags = local.tags
}

## --------------------------------------
##  PASSWORDS
## --------------------------------------

resource "random_password" "password" {
  count = var.name == "" ? 0 : 1

  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

resource "azurerm_key_vault_secret" "admin_password" {
  count = var.name == "" ? 0 : 1

  name         = "${var.name}-admin-password"
  value        = random_password.password[0].result
  key_vault_id = var.key_vault_id
}

## --------------------------------------
##  ADITIONAL DATA DISKS
## --------------------------------------

resource "azurerm_managed_disk" "disk" {
  count = var.name == "" ? 0 : length(var.data_disks)

  name                = "disk-${var.name}-${var.data_disks[count.index].type}-${format("%02s", count.index + 1)}"
  location            = var.location
  resource_group_name = var.rg_name

  storage_account_type = var.data_disks[count.index].storage_account_type
  disk_size_gb         = var.data_disks[count.index].disk_size_gb
  create_option        = "Empty"
  zone                 = var.zone

  lifecycle {
    ignore_changes = all
  }

  tags = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_attachment" {
  count = var.name == "" ? 0 : length(var.data_disks)

  managed_disk_id    = azurerm_managed_disk.disk[count.index].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm[0].id
  lun                = var.data_disks[count.index].lun
  caching            = var.data_disks[count.index].caching
}

resource "azurerm_virtual_machine_extension" "disk_init" {
  count = length(azurerm_managed_disk.disk) == 0 ? 0 : 1

  depends_on = [azurerm_virtual_machine_data_disk_attachment.disk_attachment]

  name                 = "DataDiskInit"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[0].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(local.format_disk)}')) | Out-File -filepath FormatDisk.ps1\" && powershell -ExecutionPolicy Unrestricted -File FormatDisk.ps1"
    }
SETTINGS

  tags = var.tags
}

## --------------------------------------
##  DOMAIN CONTROLLER JOIN EXTENSION
## --------------------------------------

resource "azurerm_virtual_machine_extension" "domjoin" {
  count = var.name == "" ? 0 : 1

  depends_on = [azurerm_windows_virtual_machine.vm]

  name                       = "domjoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[0].id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  # What the settings mean: https://docs.microsoft.com/en-us/windows/desktop/api/lmjoin/nf-lmjoin-netjoindomain
  settings = <<SETTINGS
    {
      "Name": "${var.dc_domain}",
      "OUPath": "${var.dc_ou_path}",
      "User": "${var.dc_domain}\\${var.dc_username}",
      "Restart": "true",
      "Options": "3"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "${data.azurerm_key_vault_secret.domainjoin[0].value}"
    }
PROTECTED_SETTINGS

}

data "azurerm_key_vault_secret" "domainjoin" {
  count = var.name == "" ? 0 : 1

  name         = "svc-domainjoin"
  key_vault_id = var.key_vault_id
}

## -----------------------------------------------------------
##  Azure Monitor Windows Agent Extension
## -----------------------------------------------------------

resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  count = var.enable_azure_monitor_agent ? 1 : 0

  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[0].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}
