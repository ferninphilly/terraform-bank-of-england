output "server_id" {
  description = "ID of the MSSQL server"
  value       = azurerm_mssql_server.main.id
}

output "server_name" {
  description = "Name of the MSSQL server"
  value       = azurerm_mssql_server.main.name
}

output "server_fqdn" {
  description = "Fully qualified domain name of the server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "database_ids" {
  description = "Map of database names to database IDs"
  value = {
    for k, v in azurerm_mssql_database.main : k => v.id
  }
}

output "database_names" {
  description = "List of database names"
  value       = keys(azurerm_mssql_database.main)
}

output "administrator_login" {
  description = "Administrator login"
  value       = var.administrator_login
  sensitive   = true
}

