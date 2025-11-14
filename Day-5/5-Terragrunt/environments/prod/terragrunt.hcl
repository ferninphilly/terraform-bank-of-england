# Production environment configuration

include "root" {
  path = find_in_parent_folders()
}

# Before hooks for production
terraform {
  before_hook "validate" {
    commands     = ["apply", "plan"]
    execute      = ["echo", "Validating production deployment..."]
    run_on_error = false
  }
  
  after_hook "notify" {
    commands     = ["apply"]
    execute      = ["echo", "Production deployment completed"]
    run_on_error = false
  }
}

inputs = {
  environment = "prod"
  
  # Production-specific configurations
  instance_count = 3
  vm_size        = "Standard_D2s_v3"
  
  common_tags = {
    ManagedBy   = "Terragrunt"
    Environment = "prod"
    CostCenter  = "production"
  }
  
  location = "eastus2"
}

