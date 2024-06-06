#--------------------
# Data declarations
#--------------------


#--------------------
# Local declarations
#--------------------

locals {
  tags = var.tags
}

#--------------------------
# Azure Resource Group
# -------------------------

resource "azurerm_resource_group" "rg" {
  name     = var.name
  location = var.location

  tags = local.tags
}

resource "azurerm_management_lock" "resource-group-level-lock" {
  count = var.lock_level == "" ? 0 : 1

  name       = "${var.name}-level-lock"
  scope      = azurerm_resource_group.rg.id
  lock_level = var.lock_level
  notes      = "Resource Group '${var.name}' is locked with '${var.lock_level}' level."
}