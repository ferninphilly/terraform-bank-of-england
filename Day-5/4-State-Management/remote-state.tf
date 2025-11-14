# TODO: Exercise 4 - Remote State Data Source
# Reference state from another Terraform configuration
# Example:
# data "terraform_remote_state" "network" {
#   backend = "azurerm"
#   config = {
#     resource_group_name  = "tfstate-rg"
#     storage_account_name = "tfstatestorage"
#     container_name       = "tfstate"
#     key                  = "network.terraform.tfstate"
#   }
# }
#
# Then use: data.terraform_remote_state.network.outputs.vnet_id

