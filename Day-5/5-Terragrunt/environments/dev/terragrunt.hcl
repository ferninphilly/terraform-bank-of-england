# Dev environment configuration
# Inherits from root terragrunt.hcl

include "root" {
  path = find_in_parent_folders()
}

# Override inputs for dev environment
inputs = {
  environment = "dev"
  
  # Dev-specific configurations
  instance_count = 1
  vm_size        = "Standard_B1s"
  
  # Override common tags
  common_tags = {
    ManagedBy   = "Terragrunt"
    Environment = "dev"
    CostCenter  = "development"
  }
  
  # Dev-specific location
  location = "eastus"
}

# TODO: Add dependency blocks if this environment depends on other modules
# Example:
# dependency "network" {
#   config_path = "../network"
# }

