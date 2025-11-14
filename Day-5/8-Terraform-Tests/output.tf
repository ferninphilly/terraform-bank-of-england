output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.example.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.example.location
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.example.name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.example.id
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = var.create_vnet ? azurerm_virtual_network.example[0].id : null
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = var.create_vnet ? azurerm_virtual_network.example[0].name : null
}

