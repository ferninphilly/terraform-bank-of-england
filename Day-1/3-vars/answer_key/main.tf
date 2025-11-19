terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.8.0"
    }
  }
  required_version = ">=1.5.7"
}

provider "azurerm" {
  # subscription_id is required. Ensure one of the following is set:
  # 1. Environment variable: ARM_SUBSCRIPTION_ID (recommended)
  #    Run: export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
  # 2. Pass as variable: terraform plan -var="subscription_id=$(az account show --query id -o tsv)"
  subscription_id = var.subscription_id != "" ? var.subscription_id : null
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "${local.resource_prefix}-resources"
  location = var.location
}

# Storage Account
resource "azurerm_storage_account" "example" {
  name                     = "${local.resource_prefix}storage"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = merge(local.common_tags, {
    environment = var.environment
  })
}

