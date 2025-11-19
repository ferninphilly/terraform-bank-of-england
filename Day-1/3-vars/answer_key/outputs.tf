output "storage_account_name" {
  value       = azurerm_storage_account.example.name
  description = "The name of the storage account"
}

output "environment_value" {
  value       = var.environment
  description = "Shows the resolved value of the environment variable (for testing precedence)"
}

output "resource_group_name" {
  value       = azurerm_resource_group.example.name
  description = "The name of the resource group"
}

output "resource_group_location" {
  value       = azurerm_resource_group.example.location
  description = "The location of the resource group"
}

output "common_tags" {
  value       = local.common_tags
  description = "The common tags applied to resources"
}

