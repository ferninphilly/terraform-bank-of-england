terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 4.8.0"
    }
  }
  required_version = ">=1.5.7"
}

provider "azurerm" {
    features {
      
    }
  
}
variable "environment" {
    type = string
    description = "the env type"
    default = "staging"
  
}

locals {
  common_tags = {
    environment = "dev"
    lob = "banking"
    stage = "alpha"
  }
}
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_storage_account" "example" {
 
  name                     = "boerg"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location # implicit dependency
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = merge(local.common_tags, {
    environment = var.environment  # This will show variable precedence
  })
}

output "storage_account_name" {
  value       = azurerm_storage_account.example.name
  description = "The name of the storage account"
}

output "environment_value" {
  value       = var.environment
  description = "Shows the resolved value of the environment variable (for testing precedence)"
}