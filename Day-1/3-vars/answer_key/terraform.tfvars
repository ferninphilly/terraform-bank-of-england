# terraform.tfvars - Variable values for this deployment
# This file overrides default values in variables.tf

environment = "demo"
location    = "West Europe"

# Note: To test variable precedence:
# 1. Remove this file and run terraform plan (uses default "staging")
# 2. Keep this file and run terraform plan (uses "demo")
# 3. Set TF_VAR_environment="production" and run terraform plan (uses "production")
# 4. Run terraform plan -var="environment=development" (uses "development")

