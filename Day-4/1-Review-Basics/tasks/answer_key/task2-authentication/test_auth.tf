# test_auth.tf - Test Terraform configuration to verify Azure authentication
#
# This file can be used to test that Terraform can authenticate with Azure.
# It doesn't create any resources, just reads subscription information.
#
# Usage:
#   1. Ensure environment variables are set (run: source ./set_vars.sh)
#   2. Run: terraform init
#   3. Run: terraform plan
#   4. If successful, authentication is working!

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Test data source - doesn't create anything, just reads
data "azurerm_subscription" "current" {}

output "subscription_id" {
  description = "Current subscription ID"
  value       = data.azurerm_subscription.current.id
}

output "subscription_display_name" {
  description = "Current subscription display name"
  value       = data.azurerm_subscription.current.display_name
}

output "subscription_tenant_id" {
  description = "Current subscription tenant ID"
  value       = data.azurerm_subscription.current.tenant_id
}

output "authentication_status" {
  description = "Authentication test status"
  value       = "✓ Successfully authenticated with Azure!"
}

