# Use the MSSQL Server module
module "mssql_server" {
  source = "./modules/mssql-server"
  
  server_name                = var.sql_server_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  administrator_login        = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
  version                    = var.sql_version
  
  databases = {
    "core-banking" = {
      collation     = "SQL_Latin1_General_CP1_CI_AS"
      license_type  = "LicenseIncluded"
      max_size_gb   = 50
      sku_name      = "S0"
      create_schema = true
      schema_name   = "Banking"
    }
    "reporting" = {
      collation     = "SQL_Latin1_General_CP1_CI_AS"
      license_type  = "LicenseIncluded"
      max_size_gb   = 100
      sku_name      = "S1"
      create_schema = true
      schema_name   = "Reporting"
    }
  }
  
  firewall_rules = {
    "allow-azure" = {
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    }
  }
  
  run_sql_scripts = var.run_sql_scripts
  tags            = var.tags
}

