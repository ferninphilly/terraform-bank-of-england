variable "server_name" {
  description = "Name of the MSSQL server (must be globally unique)"
  type        = string
  
  validation {
    condition     = length(var.server_name) >= 3 && length(var.server_name) <= 63
    error_message = "SQL server name must be between 3 and 63 characters."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the server"
  type        = string
  
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2",
      "westeurope", "northeurope"
    ], var.location)
    error_message = "Location must be in allowed regions."
  }
}

variable "administrator_login" {
  description = "Administrator login for the SQL server"
  type        = string
  default     = "sqladmin"
  
  validation {
    condition     = length(var.administrator_login) >= 1 && length(var.administrator_login) <= 128
    error_message = "Admin login must be between 1 and 128 characters."
  }
}

variable "administrator_login_password" {
  description = "Administrator password for the SQL server"
  type        = string
  sensitive   = true
  default     = null
}

variable "version" {
  description = "SQL Server version"
  type        = string
  default     = "12.0"
  
  validation {
    condition     = contains(["12.0", "2.0"], var.version)
    error_message = "SQL Server version must be 12.0 (SQL Server 2014) or 2.0 (SQL Server 2022)."
  }
}

variable "databases" {
  description = "Map of databases to create"
  type = map(object({
    collation     = string
    license_type  = string
    max_size_gb   = number
    sku_name      = string
    create_schema = bool
    schema_name   = string
  }))
  default = {}
}

variable "firewall_rules" {
  description = "Map of firewall rules to create"
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "run_sql_scripts" {
  description = "Whether to run SQL initialization scripts"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

