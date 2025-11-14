# TODO: Output workspace information and resource details

output "workspace" {
  value = terraform.workspace
}

output "resource_group_name" {
  value = azurerm_resource_group.example.name
}

