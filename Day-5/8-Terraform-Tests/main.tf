# Infrastructure to test
# This should be a simple but comprehensive infrastructure that we can test

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location

  tags = var.common_tags
}

resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type

  tags = var.common_tags
}

resource "azurerm_virtual_network" "example" {
  count               = var.create_vnet ? 1 : 0
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = var.common_tags
}

