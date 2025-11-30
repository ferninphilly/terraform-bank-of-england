variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "banking-mssql-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
  
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2",
      "westeurope", "northeurope"
    ], var.location)
    error_message = "Location must be in allowed regions."
  }
}

variable "sql_server_name" {
  description = "Name of the MSSQL server (must be globally unique)"
  type        = string
  default     = "banking-sql-server"
  
  validation {
    condition     = length(var.sql_server_name) >= 3 && length(var.sql_server_name) <= 63
    error_message = "SQL server name must be between 3 and 63 characters."
  }
}

variable "sql_admin_login" {
  description = "Administrator login for SQL server"
  type        = string
  default     = "sqladmin"
  
  validation {
    condition     = length(var.sql_admin_login) >= 1 && length(var.sql_admin_login) <= 128
    error_message = "Admin login must be between 1 and 128 characters."
  }
}

variable "sql_admin_password" {
  description = "Administrator password for SQL server"
  type        = string
  sensitive   = true
  default     = null
}

variable "sql_version" {
  description = "SQL Server version"
  type        = string
  default     = "12.0"
}

variable "run_sql_scripts" {
  description = "Whether to run SQL initialization scripts"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "Core-Banking-System"
    ManagedBy   = "Terraform"
    Compliance  = "PCI-DSS"
  }
}

