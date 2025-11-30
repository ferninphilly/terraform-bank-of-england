output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.example.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.example.name
}

output "state_backend_info" {
  description = "Information about the remote state backend"
  value = {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatestorage1234"  # Your state storage account
    container_name       = "tfstate"
    state_file_key       = "example.terraform.tfstate"
  }
}

