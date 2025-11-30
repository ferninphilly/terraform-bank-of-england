# MSSQL Server Outputs
output "sql_server_id" {
  description = "ID of the MSSQL server"
  value       = module.mssql_server.server_id
}

output "sql_server_name" {
  description = "Name of the MSSQL server"
  value       = module.mssql_server.server_name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the server"
  value       = module.mssql_server.server_fqdn
}

output "database_ids" {
  description = "Map of database names to database IDs"
  value       = module.mssql_server.database_ids
}

output "connection_strings" {
  description = "Connection strings for databases (sensitive)"
  value = {
    for db_name, db_id in module.mssql_server.database_ids : db_name => "Server=tcp:${module.mssql_server.server_fqdn},1433;Initial Catalog=${db_name};Persist Security Info=False;User ID=${var.sql_admin_login};Password=***;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
  sensitive = true
}

output "sql_scripts_executed" {
  description = "Whether SQL scripts were executed"
  value       = var.run_sql_scripts
}

