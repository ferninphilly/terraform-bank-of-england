# Example Terraform configuration using remote state backend

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "backend-example-rg"
  location = "eastus"

  tags = {
    Environment = "example"
    ManagedBy   = "Terraform"
  }
}

# Storage Account (example resource)
resource "azurerm_storage_account" "example" {
  name                     = "backendexample${substr(md5(azurerm_resource_group.example.name), 0, 8)}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "example"
    ManagedBy   = "Terraform"
  }
}

