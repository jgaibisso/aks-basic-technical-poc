## --------------------------------------
##  LOCAL VARIABLES
## --------------------------------------

locals {
  tags = var.tags
}

## --------------------------------------
##  NETWORK INTERFACE (NIC)
## --------------------------------------

resource "azurerm_network_interface" "nic" {
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

resource "tls_private_key" "tls_pk" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "azurerm_key_vault_secret" "priv_key" {
  count = var.key_vault_id == null ? 0 : 1

  name         = "${var.name}-priv-key"
  value        = tls_private_key.tls_pk.private_key_openssh
  key_vault_id = var.key_vault_id
}

## --------------------------------------
##  VIRTUAL MACHINE
## --------------------------------------

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.name
  admin_username                  = var.admin_username
  location                        = var.location
  resource_group_name             = var.rg_name
  size                            = var.vm_size
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.nic.id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  zone = var.zone

  os_disk {
    name                 = "osdisk-${var.name}"
    caching              = "ReadWrite"
    storage_account_type = var.os_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  admin_ssh_key {
    username   = var.username
    public_key = tls_private_key.tls_pk.public_key_openssh
  }

  custom_data = base64encode(file("${path.module}/cloud-init.yml"))

  tags = local.tags
}

resource "azurerm_virtual_machine_extension" "ama_linux" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}
