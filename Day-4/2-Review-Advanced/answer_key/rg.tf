resource "azurerm_resource_group" "main" {
  name     = local.resource_names.resource_group
  location = var.location

  tags = local.common_tags
}

