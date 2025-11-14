# TODO: Exercise 2 - Workspace Configuration
# - Use terraform.workspace in resource naming
# - Create workspace-specific resources
# - Use workspace in tags

resource "azurerm_resource_group" "example" {
  name     = "rg-${terraform.workspace}-example"
  location = var.location
  
  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

# TODO: Add more resources that use workspace name

