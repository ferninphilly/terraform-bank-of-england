terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatestorage"
    container_name       = "tfstate"
    key                  = "docker-deployment.terraform.tfstate"
  }
}

# Note: This is a template. Actual values should be provided via backend-config or environment variables.
# Example initialization:
# terraform init -backend-config="resource_group_name=tfstate-rg" \
#                -backend-config="storage_account_name=tfstate12345" \
#                -backend-config="container_name=tfstate" \
#                -backend-config="key=prod.terraform.tfstate"