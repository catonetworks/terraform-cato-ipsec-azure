locals {
  resource_group_name = var.build_azure_resource_group ? azurerm_resource_group.network_resource_group[0].name : var.azure_resource_group_name
  vnet_name           = var.build_azure_vng_vnet ? azurerm_virtual_network.vng_virtual_network[0].name : var.azure_vnet_name
}