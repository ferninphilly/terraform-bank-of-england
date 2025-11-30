# Task: Creating an MSSQL Server Module for Banking System

This task focuses on creating a comprehensive MSSQL Server module for a banking system that includes database creation, schema setup, tables, and stored procedures for managing customers, accounts, transactions, and loans.

## Learning Objectives

By the end of this task, you will:
- Create an MSSQL Server using Terraform
- Create multiple databases
- Understand how to run SQL scripts with Terraform
- Create schemas, tables, and stored procedures
- Configure firewall rules for database access
- Use modules to organize database infrastructure

## Important Note: Terraform Options for MSSQL

### Option 1: Azure Provider (azurerm) - Infrastructure Only

**What the Azure Provider CAN do:**
- ✅ Create MSSQL Server (`azurerm_mssql_server`)
- ✅ Create MSSQL Databases (`azurerm_mssql_database`)
- ✅ Configure firewall rules (`azurerm_mssql_firewall_rule`)
- ✅ Set server-level configurations

**What the Azure Provider CANNOT do:**
- ❌ Create tables, schemas, or stored procedures (no native resources)

**Solution:** Use `null_resource` with `local-exec` provisioner to run SQL scripts using `sqlcmd` or Azure CLI.

### Option 2: MSSQL Provider (Community) - SQL Objects

There is a **community-maintained MSSQL provider** that can manage SQL objects directly:

**Provider:** `terraform-provider-mssql` by PGSSoft
**GitHub:** https://github.com/PGSSoft/terraform-provider-mssql

**What the MSSQL Provider CAN do:**
- ✅ Create tables
- ✅ Create schemas
- ✅ Create stored procedures
- ✅ Create database users and roles
- ✅ Manage SQL objects as Terraform resources

**Limitations:**
- Community-maintained (may not be as actively updated)
- Requires direct database connection (not Azure-specific)

**This task uses Option 1** (Azure provider + provisioners) because:
- Uses official Azure provider (more reliable)
- Works well for Azure SQL Database
- Easier to set up (no additional provider needed)
- SQL scripts are version-controlled and transparent

## Task Overview

Create a reusable **MSSQL Server module** that includes:
- MSSQL Server with configurable settings
- Multiple databases
- Firewall rules
- SQL scripts to create schemas, tables, and stored procedures

### Module Structure

```
modules/
└── mssql-server/
    ├── main.tf          # MSSQL Server, databases, firewall rules
    ├── variables.tf     # Module variables
    ├── outputs.tf      # Module outputs
    └── sql/
        ├── init.sql    # SQL script for schemas, tables, procedures
        └── seed.sql    # Optional seed data
```

### Root Module Structure

```
.
├── main.tf              # Uses MSSQL module
├── variables.tf         # Root module variables
├── outputs.tf           # Root module outputs
├── provider.tf
├── backend.tf
└── modules/
    └── mssql-server/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── sql/
            └── init.sql
```

## Step-by-Step Instructions

### Step 1: Create Module Directory Structure

```bash
mkdir -p modules/mssql-server/sql
touch modules/mssql-server/main.tf
touch modules/mssql-server/variables.tf
touch modules/mssql-server/outputs.tf
touch modules/mssql-server/sql/init.sql
```

### Step 2: Define Module Variables

**File: `modules/mssql-server/variables.tf`**

```hcl
variable "server_name" {
  description = "Name of the MSSQL server (must be globally unique)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the server"
  type        = string
}

variable "administrator_login" {
  description = "Administrator login for the SQL server"
  type        = string
  default     = "sqladmin"
}

variable "administrator_login_password" {
  description = "Administrator password for the SQL server"
  type        = string
  sensitive   = true
}

variable "version" {
  description = "SQL Server version"
  type        = string
  default     = "12.0"
}

variable "databases" {
  description = "Map of databases to create"
  type = map(object({
    collation      = string
    license_type   = string
    max_size_gb    = number
    sku_name       = string
    create_schema  = bool
    schema_name    = string
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
```

### Step 3: Create MSSQL Server and Databases

**File: `modules/mssql-server/main.tf`**

```hcl
# Generate random password if not provided
resource "random_password" "sql_password" {
  count   = var.administrator_login_password == null ? 1 : 0
  length  = 16
  special = true
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
```

### Step 4: Create SQL Initialization Script

**File: `modules/mssql-server/sql/init.sql`**

```sql
-- Create Schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = '$(SCHEMA_NAME)')
BEGIN
    EXEC('CREATE SCHEMA [$(SCHEMA_NAME)]')
END
GO

-- Create Table: Customers
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[Customers]') AND type in (N'U'))
BEGIN
    CREATE TABLE [$(SCHEMA_NAME)].[Customers] (
        CustomerID INT PRIMARY KEY IDENTITY(1,1),
        FirstName NVARCHAR(50) NOT NULL,
        LastName NVARCHAR(50) NOT NULL,
        Email NVARCHAR(100) NOT NULL UNIQUE,
        Phone NVARCHAR(20),
        DateOfBirth DATE NOT NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1
    )
END
GO

-- Create Table: AccountTypes
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[AccountTypes]') AND type in (N'U'))
BEGIN
    CREATE TABLE [$(SCHEMA_NAME)].[AccountTypes] (
        AccountTypeID INT PRIMARY KEY IDENTITY(1,1),
        TypeCode NVARCHAR(10) NOT NULL UNIQUE, -- CHECKING, SAVINGS, MONEYMARKET
        TypeName NVARCHAR(50) NOT NULL,
        InterestRate DECIMAL(5,4) DEFAULT 0.0000,
        MinimumBalance DECIMAL(10,2) DEFAULT 0
    )
END
GO

-- Create Table: Accounts
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[Accounts]') AND type in (N'U'))
BEGIN
    CREATE TABLE [$(SCHEMA_NAME)].[Accounts] (
        AccountID INT PRIMARY KEY IDENTITY(1,1),
        AccountNumber NVARCHAR(20) NOT NULL UNIQUE,
        CustomerID INT NOT NULL,
        AccountTypeID INT NOT NULL,
        Balance DECIMAL(18,2) DEFAULT 0.00 CHECK (Balance >= 0),
        OpenDate DATETIME DEFAULT GETDATE(),
        Status NVARCHAR(20) DEFAULT 'Active',
        FOREIGN KEY (CustomerID) REFERENCES [$(SCHEMA_NAME)].[Customers](CustomerID),
        FOREIGN KEY (AccountTypeID) REFERENCES [$(SCHEMA_NAME)].[AccountTypes](AccountTypeID)
    )
END
GO

-- Create Table: Transactions
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[Transactions]') AND type in (N'U'))
BEGIN
    CREATE TABLE [$(SCHEMA_NAME)].[Transactions] (
        TransactionID BIGINT PRIMARY KEY IDENTITY(1,1),
        TransactionNumber NVARCHAR(30) NOT NULL UNIQUE,
        AccountID INT NOT NULL,
        TransactionType NVARCHAR(20) NOT NULL, -- DEPOSIT, WITHDRAWAL, TRANSFER
        Amount DECIMAL(18,2) NOT NULL CHECK (Amount > 0),
        BalanceAfter DECIMAL(18,2) NOT NULL,
        TransactionDate DATETIME DEFAULT GETDATE(),
        Status NVARCHAR(20) DEFAULT 'Completed',
        FOREIGN KEY (AccountID) REFERENCES [$(SCHEMA_NAME)].[Accounts](AccountID)
    )
END
GO

-- Create Stored Procedure: GetCustomerAccounts
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[GetCustomerAccounts]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [$(SCHEMA_NAME)].[GetCustomerAccounts]
GO

CREATE PROCEDURE [$(SCHEMA_NAME)].[GetCustomerAccounts]
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        a.AccountID,
        a.AccountNumber,
        a.Balance,
        a.Status,
        at.TypeName AS AccountType
    FROM [$(SCHEMA_NAME)].[Accounts] a
    INNER JOIN [$(SCHEMA_NAME)].[AccountTypes] at ON a.AccountTypeID = at.AccountTypeID
    WHERE a.CustomerID = @CustomerID
      AND a.Status = 'Active'
    ORDER BY a.OpenDate DESC
END
GO

-- Create Stored Procedure: ProcessTransaction
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[$(SCHEMA_NAME)].[ProcessTransaction]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [$(SCHEMA_NAME)].[ProcessTransaction]
GO

CREATE PROCEDURE [$(SCHEMA_NAME)].[ProcessTransaction]
    @AccountID INT,
    @TransactionType NVARCHAR(20),
    @Amount DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION
    
    BEGIN TRY
        -- Validate account exists and is active
        IF NOT EXISTS (SELECT 1 FROM [$(SCHEMA_NAME)].[Accounts] WHERE AccountID = @AccountID AND Status = 'Active')
        BEGIN
            RAISERROR('Account does not exist or is not active', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Get current balance and calculate new balance
        DECLARE @CurrentBalance DECIMAL(18,2)
        DECLARE @NewBalance DECIMAL(18,2)
        
        SELECT @CurrentBalance = Balance
        FROM [$(SCHEMA_NAME)].[Accounts]
        WHERE AccountID = @AccountID
        
        -- Calculate new balance based on transaction type
        IF @TransactionType = 'WITHDRAWAL'
        BEGIN
            IF @CurrentBalance < @Amount
            BEGIN
                RAISERROR('Insufficient funds', 16, 1)
                ROLLBACK TRANSACTION
                RETURN
            END
            SET @NewBalance = @CurrentBalance - @Amount
        END
        ELSE IF @TransactionType = 'DEPOSIT'
        BEGIN
            SET @NewBalance = @CurrentBalance + @Amount
        END
        
        -- Update account balance
        UPDATE [$(SCHEMA_NAME)].[Accounts]
        SET Balance = @NewBalance
        WHERE AccountID = @AccountID
        
        -- Create transaction record
        INSERT INTO [$(SCHEMA_NAME)].[Transactions] (
            TransactionNumber,
            AccountID,
            TransactionType,
            Amount,
            BalanceAfter
        )
        VALUES (
            'TXN-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + CAST(NEXT VALUE FOR [dbo].[TransactionSequence] AS NVARCHAR),
            @AccountID,
            @TransactionType,
            @Amount,
            @NewBalance
        )
        
        SELECT 'Success' AS Status, @NewBalance AS NewBalance
        
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        RAISERROR(ERROR_MESSAGE(), 16, 1)
    END CATCH
END
GO
```

### Step 5: Run SQL Scripts with null_resource

**Add to `modules/mssql-server/main.tf`:**

```hcl
# Run SQL initialization scripts
resource "null_resource" "sql_init" {
  for_each = var.run_sql_scripts ? var.databases : {}
  
  triggers = {
    database_id = azurerm_mssql_database.main[each.key].id
    script_hash = filemd5("${path.module}/sql/init.sql")
  }

  provisioner "local-exec" {
    command = <<-EOT
      sqlcmd -S ${azurerm_mssql_server.main.fully_qualified_domain_name} \
        -d ${each.key} \
        -U ${var.administrator_login} \
        -P "${var.administrator_login_password != null ? var.administrator_login_password : random_password.sql_password[0].result}" \
        -i ${path.module}/sql/init.sql \
        -v SCHEMA_NAME="${each.value.schema_name}" \
        -C
    EOT
  }

  depends_on = [
    azurerm_mssql_database.main,
    azurerm_mssql_firewall_rule.main
  ]
}
```

**Note:** Requires `sqlcmd` to be installed. Alternative: Use Azure CLI.

### Step 6: Create Module Outputs

**File: `modules/mssql-server/outputs.tf`**

```hcl
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

output "administrator_login" {
  description = "Administrator login"
  value       = var.administrator_login
  sensitive   = true
}
```

### Step 7: Use Module in Root Module

**File: `main.tf`**

```hcl
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
```

## Understanding SQL Script Execution

### Why null_resource? (Azure Provider Approach)

The **Azure provider (azurerm)** doesn't have native resources for:
- Creating tables
- Creating schemas
- Creating stored procedures
- Running SQL scripts

**Solution:** Use `null_resource` with `local-exec` provisioner to run SQL scripts.

### Alternative: MSSQL Provider (Community)

There IS a community MSSQL provider that can manage SQL objects as Terraform resources:

**Provider:** `terraform-provider-mssql` (PGSSoft)

**Setup:**
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    mssql = {
      source  = "PGSSoft/mssql"
      version = "~> 1.0"
    }
  }
}

provider "mssql" {
  hostname = azurerm_mssql_server.main.fully_qualified_domain_name
  port     = 1433
  database = azurerm_mssql_database.main["ecommerce"].name
  username = azurerm_mssql_server.main.administrator_login
  password = var.sql_admin_password
}
```

**Usage:**
```hcl
# Create schema
resource "mssql_schema" "sales" {
  database = azurerm_mssql_database.main["ecommerce"].name
  name     = "Sales"
}

# Create table
resource "mssql_table" "users" {
  database = azurerm_mssql_database.main["ecommerce"].name
  schema   = mssql_schema.sales.name
  name     = "Users"
  
  column {
    name     = "UserID"
    type     = "int"
    nullable = false
    identity = true
  }
  column {
    name     = "Username"
    type     = "nvarchar(50)"
    nullable = false
  }
}
```

**Pros:**
- ✅ SQL objects as Terraform resources
- ✅ Better state management
- ✅ Idempotent by design

**Cons:**
- ❌ Community-maintained (less official support)
- ❌ Requires direct database connection
- ❌ May have compatibility issues

**This task uses the Azure provider + provisioners approach** for simplicity and reliability with Azure SQL Database.

### How It Works

1. **null_resource**: A "fake" resource that triggers actions
2. **local-exec**: Runs commands on your local machine
3. **sqlcmd**: Microsoft's SQL command-line tool
4. **Triggers**: Re-runs when dependencies change

### Alternative: Using Azure CLI

If `sqlcmd` is not available, use Azure CLI:

```hcl
provisioner "local-exec" {
  command = <<-EOT
    az sql db execute \
      --server-name ${azurerm_mssql_server.main.name} \
      --database-name ${each.key} \
      --admin-user ${var.administrator_login} \
      --admin-password "${var.administrator_login_password}" \
      --file-path ${path.module}/sql/init.sql
  EOT
}
```

## Prerequisites

### Install sqlcmd

**Linux (Ubuntu/Debian):**
```bash
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
```

**macOS:**
```bash
brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
brew update
HOMEBREW_ACCEPT_EULA=Y brew install mssql-tools
```

**Windows:**
Download from: https://docs.microsoft.com/sql/tools/sqlcmd-utility

### Or Use Azure CLI

```bash
# Install Azure CLI (if not already installed)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

## Key Concepts

### 1. MSSQL Server Configuration

```hcl
resource "azurerm_mssql_server" "main" {
  name                         = "my-sql-server"
  administrator_login          = "sqladmin"
  administrator_login_password = "SecurePassword123!"
  version                      = "12.0"  # SQL Server 2014
  minimum_tls_version          = "1.2"   # Security requirement
}
```

### 2. Database Configuration

```hcl
resource "azurerm_mssql_database" "main" {
  name        = "mydatabase"
  server_id   = azurerm_mssql_server.main.id
  sku_name    = "Basic"      # Pricing tier
  max_size_gb = 10           # Maximum size
  collation   = "SQL_Latin1_General_CP1_CI_AS"
}
```

**Common SKU Names:**
- `Basic` - Cheapest, limited performance
- `S0`, `S1`, `S2`, `S3` - Standard tier (S0 = 10 DTU)
- `P1`, `P2`, `P4`, `P6` - Premium tier

### 3. Firewall Rules

```hcl
resource "azurerm_mssql_firewall_rule" "main" {
  name             = "allow-azure"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"  # Allows Azure services
}
```

### 4. SQL Script Execution

```hcl
resource "null_resource" "sql_init" {
  provisioner "local-exec" {
    command = "sqlcmd -S server.database.windows.net -d database -U user -P password -i script.sql"
  }
}
```

## Best Practices

1. ✅ **Use random_password**: Generate secure passwords
2. ✅ **Mark passwords sensitive**: Use `sensitive = true`
3. ✅ **Firewall rules**: Restrict access, don't allow 0.0.0.0/0
4. ✅ **SQL scripts**: Version control your SQL scripts
5. ✅ **Error handling**: Check if objects exist before creating
6. ✅ **Idempotency**: SQL scripts should be idempotent (can run multiple times)

## Troubleshooting

### Error: "sqlcmd: command not found"

**Solution:** Install sqlcmd or use Azure CLI alternative.

### Error: "Login failed"

**Solution:**
- Verify firewall rules allow your IP
- Check username/password
- Ensure server is accessible

### Error: "Database does not exist"

**Solution:**
- Ensure database is created before running scripts
- Check `depends_on` in null_resource

### SQL Script Errors

**Solution:**
- Test SQL scripts manually first
- Use `IF NOT EXISTS` checks
- Verify schema names and object names

## Deliverables

- ✅ Complete MSSQL Server module
- ✅ Multiple databases configuration
- ✅ Firewall rules
- ✅ SQL scripts for schemas, tables, procedures
- ✅ null_resource for script execution
- ✅ Root module using the module

## Next Steps

After completing this task:
- Add more database configurations
- Create additional stored procedures
- Add database backups configuration
- Implement database auditing
- Create database users and roles

