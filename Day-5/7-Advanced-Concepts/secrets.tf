# TODO: Exercise 3 - Secret Management
# - Create or reference Azure Key Vault
# - Store secrets in Key Vault
# - Retrieve secrets using data sources
# - Use secrets in resources (mark as sensitive)

# Example:
# data "azurerm_key_vault" "example" {
#   name                = var.key_vault_name
#   resource_group_name = var.resource_group_name
# }
#
# data "azurerm_key_vault_secret" "example" {
#   name         = "my-secret"
#   key_vault_id = data.azurerm_key_vault.example.id
# }
#
# resource "azurerm_storage_account" "example" {
#   # Use secret value (marked as sensitive)
#   account_key = data.azurerm_key_vault_secret.example.value
# }

