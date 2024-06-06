#--------------------
# Local declarations
#--------------------

#--------------------------
# Azure Subnets
# -------------------------

resource "azurerm_subnet" "snet" {

  name                 = var.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.snet_address_range

  service_endpoints = var.service_endpoints

  private_endpoint_network_policies_enabled     = var.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = var.private_link_service_network_policies_enabled

  dynamic "delegation" {
    for_each = var.service_delegation_name == null ? [] : [1]
    content {
      name = "delegation"
      service_delegation {
        name    = var.service_delegation_name
        actions = var.service_delegation_actions
      }
    }
  }

  lifecycle {
    ignore_changes = [delegation]
  }
}
