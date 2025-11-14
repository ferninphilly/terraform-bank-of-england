# TODO: Create workspace-specific configurations
# Use terraform.workspace to set different values per environment
# Example:
# locals {
#   instance_count = terraform.workspace == "prod" ? 3 : 1
#   vm_size       = terraform.workspace == "prod" ? "Standard_D2s_v3" : "Standard_B1s"
# }

