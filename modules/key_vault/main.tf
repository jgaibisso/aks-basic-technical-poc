#--------------------
# Local declarations
#--------------------

locals {
  tags = var.tags
}

#--------------------
# Data declarations
#--------------------

data "azurerm_client_config" "current" {}

data "azuread_group" "g_sec_kv_admins" {
  count = var.kv_admins_ad_group == null ? 0 : 1

  display_name = var.kv_admins_ad_group
}

data "azuread_group" "g_sec_kv_readers" {
  count = var.kv_readers_ad_group == null ? 0 : 1

  display_name = var.kv_readers_ad_group
}

## --------------------------------------
##  KEY VAULT
## --------------------------------------

resource "azurerm_key_vault" "kv" {
  name = "kv-${var.name}"

  location            = var.location
  resource_group_name = var.rg_name

  tenant_id = data.azurerm_client_config.current.tenant_id

  sku_name                   = "standard"
  soft_delete_retention_days = 7

  enabled_for_deployment          = true
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  purge_protection_enabled        = false
  enable_rbac_authorization       = true

  tags = local.tags
}

resource "azurerm_key_vault_secret" "secrets" {
  for_each   = var.secret_map
  depends_on = [azurerm_role_assignment.rbac_keyvault_administrator_sp]

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.kv.id

  lifecycle {
    ignore_changes = [value, tags]
  }

}

resource "azurerm_role_assignment" "rbac_keyvault_administrator_sp" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "rbac_keyvault_administrator_ad" {
  count = var.kv_admins_ad_group == null ? 0 : 1

  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azuread_group.g_sec_kv_admins[0].object_id
}

resource "azurerm_role_assignment" "rbac_keyvault_reader_ad" {
  count = var.kv_readers_ad_group == null ? 0 : 1

  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Reader"
  principal_id         = data.azuread_group.g_sec_kv_readers[0].object_id
}

resource "azurerm_role_assignment" "rbac_keyvault_secrets_user_ad" {
  count = var.kv_readers_ad_group == null ? 0 : 1

  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azuread_group.g_sec_kv_readers[0].object_id
}

resource "azurerm_role_assignment" "rbac_keyvault_certificate_user_ad" {
  count = var.kv_readers_ad_group == null ? 0 : 1

  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Certificate User"
  principal_id         = data.azuread_group.g_sec_kv_readers[0].object_id
}

resource "azurerm_role_assignment" "rbac_keyvault_crypto_user_ad" {
  count = var.kv_readers_ad_group == null ? 0 : 1

  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = data.azuread_group.g_sec_kv_readers[0].object_id
}