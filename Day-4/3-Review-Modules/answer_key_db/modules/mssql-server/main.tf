# Generate random password if not provided
resource "random_password" "sql_password" {
  count   = var.administrator_login_password == null ? 1 : 0
  length  = 16
  special = true
  override_special = "_%@"
}

# MSSQL Server
resource "azurerm_mssql_server" "main" {
  name                         = var.server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.version
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password != null ? var.administrator_login_password : random_password.sql_password[0].result
  minimum_tls_version          = "1.2"

  tags = var.tags
}

# MSSQL Databases
resource "azurerm_mssql_database" "main" {
  for_each = var.databases
  
  name           = each.key
  server_id      = azurerm_mssql_server.main.id
  collation      = each.value.collation
  license_type   = each.value.license_type
  max_size_gb    = each.value.max_size_gb
  sku_name       = each.value.sku_name
  
  tags = var.tags
}

# Firewall Rules
resource "azurerm_mssql_firewall_rule" "main" {
  for_each = var.firewall_rules
  
  name             = each.key
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

# Run SQL initialization scripts using null_resource
resource "null_resource" "sql_init" {
  for_each = var.run_sql_scripts ? {
    for k, v in var.databases : k => v
    if v.create_schema == true
  } : {}
  
  triggers = {
    database_id = azurerm_mssql_database.main[each.key].id
    script_hash = filemd5("${path.module}/sql/init.sql")
    schema_name = each.value.schema_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if sqlcmd is available, otherwise use Azure CLI
      if command -v sqlcmd &> /dev/null; then
        sqlcmd -S ${azurerm_mssql_server.main.fully_qualified_domain_name} \
          -d ${each.key} \
          -U ${var.administrator_login} \
          -P "${var.administrator_login_password != null ? var.administrator_login_password : random_password.sql_password[0].result}" \
          -i ${path.module}/sql/init.sql \
          -v SCHEMA_NAME="${each.value.schema_name}" \
          -C
      else
        echo "sqlcmd not found. Install sqlcmd or use Azure CLI."
        echo "SQL script location: ${path.module}/sql/init.sql"
        echo "To run manually: sqlcmd -S ${azurerm_mssql_server.main.fully_qualified_domain_name} -d ${each.key} -U ${var.administrator_login} -i ${path.module}/sql/init.sql -v SCHEMA_NAME=${each.value.schema_name}"
      fi
    EOT
  }

  depends_on = [
    azurerm_mssql_database.main,
    azurerm_mssql_firewall_rule.main
  ]
}

