# Bootstrap Terraform Configuration
# This creates the Storage Account and Container for Terraform state
# Run this ONCE to set up your backend infrastructure

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Generate random suffix for storage account name (must be globally unique)
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
  numeric = true
}

# Resource Group for Terraform State Storage
resource "azurerm_resource_group" "tfstate" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Purpose     = "TerraformState"
    ManagedBy   = "Terraform"
    Environment = "shared"
  }
}

# Storage Account for Terraform State
resource "azurerm_storage_account" "tfstate" {
  name                     = "${var.storage_account_prefix}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  
  # Security settings
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
  
  # Enable versioning for state file recovery
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }
  }

  tags = {
    Purpose     = "TerraformState"
    ManagedBy   = "Terraform"
    Environment = "shared"
  }
}

# Blob Container for Terraform State Files
resource "azurerm_storage_container" "tfstate" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# Output the storage account name for use in backend configuration
output "storage_account_name" {
  description = "Name of the storage account for Terraform state"
  value       = azurerm_storage_account.tfstate.name
  sensitive   = false
}

output "container_name" {
  description = "Name of the blob container"
  value       = azurerm_storage_container.tfstate.name
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.tfstate.name
}

output "backend_config" {
  description = "Backend configuration snippet"
  value = <<-EOT
    backend "azurerm" {
      resource_group_name  = "${azurerm_resource_group.tfstate.name}"
      storage_account_name = "${azurerm_storage_account.tfstate.name}"
      container_name       = "${azurerm_storage_container.tfstate.name}"
      key                  = "terraform.tfstate"
    }
  EOT
}

