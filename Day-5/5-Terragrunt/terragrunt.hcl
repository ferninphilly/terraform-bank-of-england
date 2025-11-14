# Root Terragrunt configuration
# This file contains common configuration inherited by all environments

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
}
EOF
}

# Remote state configuration
remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatestorage"
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}

# Common inputs
inputs = {
  # Common tags
  common_tags = {
    ManagedBy   = "Terragrunt"
    Environment = "default"
  }
  
  # Default location
  location = "eastus"
}

