# Staging environment configuration

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  environment = "staging"
  
  # Staging-specific configurations
  instance_count = 2
  vm_size        = "Standard_B2s"
  
  common_tags = {
    ManagedBy   = "Terragrunt"
    Environment = "staging"
    CostCenter  = "staging"
  }
  
  location = "eastus"
}

