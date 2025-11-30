# Answer Key: MSSQL Server Module for Banking System

This directory contains a complete working example of an MSSQL Server module for a banking system that creates databases, schemas, tables, and stored procedures for managing customers, accounts, transactions, and loans.

## Overview

This example demonstrates:
- ✅ Creating MSSQL Server using Terraform
- ✅ Creating multiple databases
- ✅ Configuring firewall rules
- ✅ Running SQL scripts to create schemas, tables, and stored procedures
- ✅ Using null_resource with provisioners
- ✅ Module structure and variable passing

## Important: Terraform Provider Options

### Option 1: Azure Provider (Used Here)

**What it does:**
- Creates MSSQL Server infrastructure
- Creates databases
- Configures firewall rules

**For SQL objects (tables, schemas, procedures):**
- Uses `null_resource` with `local-exec` provisioner
- Runs SQL scripts using `sqlcmd` or Azure CLI

**Pros:**
- ✅ Official Azure provider (reliable)
- ✅ Works well with Azure SQL Database
- ✅ SQL scripts are version-controlled

### Option 2: MSSQL Provider (Community)

There IS a community MSSQL provider (`terraform-provider-mssql`) that can manage SQL objects as Terraform resources, but this example uses the Azure provider approach for simplicity and reliability.

## Directory Structure

```
answer_key_db/
├── backend.tf                    # Backend configuration
├── provider.tf                   # Provider configuration
├── variables.tf                  # Root module variables
├── main.tf                       # Root module (uses MSSQL module)
├── output.tf                     # Root module outputs
├── terraform.tfvars.example      # Example variable values
└── modules/
    └── mssql-server/
        ├── variables.tf          # Module variables
        ├── main.tf               # MSSQL Server, databases, firewall, SQL scripts
        ├── outputs.tf            # Module outputs
        └── sql/
            └── init.sql          # SQL script for schemas, tables, procedures
```

## What Gets Created

### Infrastructure (Terraform Resources)

1. **MSSQL Server** (`azurerm_mssql_server`)
   - Server name (globally unique)
   - Administrator credentials
   - Version and TLS settings

2. **MSSQL Databases** (`azurerm_mssql_database`)
   - Core Banking database (core-banking)
   - Reporting database (reporting)
   - Configurable SKU and size
   - Collation settings

3. **Firewall Rules** (`azurerm_mssql_firewall_rule`)
   - Allow Azure services (0.0.0.0) - enables access from Azure resources

### SQL Objects (via SQL Scripts)

4. **Schemas**
   - Banking schema (in core-banking database)
   - Reporting schema (in reporting database)

5. **Tables**
   - Customers - Customer information and demographics
   - AccountTypes - Account type definitions (Checking, Savings, Money Market, CD)
   - Accounts - Customer bank accounts with balances
   - TransactionTypes - Transaction type definitions (Deposit, Withdrawal, Transfer, Fee, Interest)
   - Transactions - Transaction history with balances
   - Loans - Loan accounts (Personal, Mortgage, Auto, Business)

6. **Stored Procedures**
   - GetCustomerAccounts - Retrieves all accounts for a customer
   - ProcessTransaction - Processes deposits, withdrawals, and transfers
   - GetAccountBalance - Gets account balance and transaction summary
   - TransferFunds - Transfers funds between accounts

7. **Indexes**
   - Performance indexes on Accounts, Transactions, and Loans

## Prerequisites

### 1. Install sqlcmd (Optional but Recommended)

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

**Note:** If `sqlcmd` is not installed, the provisioner will print instructions for manual execution.

### 2. Azure Authentication

Ensure you're authenticated:
```bash
az login
```

## Usage

### 1. Copy Example Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit Variables

**Important:** Update these values:

```hcl
# Must be globally unique!
sql_server_name = "banking-sql-server-12345"

# Set a strong password
sql_admin_password = "YourSecurePassword123!"
```

### 3. Initialize Terraform

```bash
terraform init
```

This downloads:
- Azure provider
- Random provider (for password generation)
- Null provider (for SQL script execution)

### 4. Review Plan

```bash
terraform plan
```

**Expected Resources:**
- 1 MSSQL Server
- 2 MSSQL Databases (core-banking, reporting)
- 2 Firewall Rules
- 2 null_resource (for SQL script execution)

### 5. Apply Configuration

```bash
terraform apply
```

**Note:** If `sqlcmd` is not installed, you'll see a message with instructions. The infrastructure will still be created, but SQL scripts won't run automatically.

### 6. Verify SQL Objects

**Option 1: Using Azure Portal**
1. Go to Azure Portal
2. Navigate to your SQL Server
3. Open Query Editor
4. Run: `SELECT * FROM Banking.Customers`

**Option 2: Using sqlcmd**
```bash
sqlcmd -S <server-fqdn> -d core-banking -U sqladmin -P "<password>" -Q "SELECT * FROM Banking.Customers"
```

## Understanding the SQL Script Execution

### How null_resource Works

```hcl
resource "null_resource" "sql_init" {
  for_each = var.run_sql_scripts ? var.databases : {}
  
  triggers = {
    database_id = azurerm_mssql_database.main[each.key].id
    script_hash = filemd5("${path.module}/sql/init.sql")
  }

  provisioner "local-exec" {
    command = "sqlcmd -S ... -d ... -i init.sql"
  }
}
```

**Key Points:**
- `null_resource` is a "fake" resource that triggers actions
- `triggers` cause re-execution when dependencies change
- `filemd5` ensures script changes trigger re-run
- `local-exec` runs commands on your local machine

### SQL Script Variables

The SQL script uses `$(SCHEMA_NAME)` which is replaced by Terraform:

```sql
-- In init.sql
CREATE SCHEMA [$(SCHEMA_NAME)]

-- Terraform replaces it with:
CREATE SCHEMA [Banking]
```

## Database Configuration

### Database SKU Options

**Basic Tier (Cheapest):**
```hcl
sku_name = "Basic"  # Limited to 2GB, 5 DTU
```

**Standard Tier:**
```hcl
sku_name = "S0"  # 10 DTU, 250GB max
sku_name = "S1"  # 20 DTU, 250GB max
sku_name = "S2"  # 50 DTU, 250GB max
sku_name = "S3"  # 100 DTU, 250GB max
```

**Premium Tier:**
```hcl
sku_name = "P1"  # 125 DTU, 500GB max
sku_name = "P2"  # 250 DTU, 500GB max
```

### Adding More Databases

Edit `main.tf`:

```hcl
databases = {
  "core-banking" = { ... }
  "reporting" = { ... }
  "compliance" = {
    collation     = "SQL_Latin1_General_CP1_CI_AS"
    license_type  = "LicenseIncluded"
    max_size_gb   = 50
    sku_name      = "S0"
    create_schema = true
    schema_name   = "Compliance"
  }
}
```

## SQL Script Details

### What the Script Creates

**Schemas:**
- `Banking` (in core-banking database)
- `Reporting` (in reporting database)

**Tables:**
1. **Customers** - Customer information
   - CustomerID (Primary Key, Identity)
   - FirstName, LastName, Email (Unique)
   - Phone, DateOfBirth, SSN
   - Address fields, CreatedDate, IsActive

2. **AccountTypes** - Account type definitions
   - AccountTypeID (Primary Key, Identity)
   - TypeCode (CHECKING, SAVINGS, MONEYMARKET, CD)
   - TypeName, InterestRate, MinimumBalance, MonthlyFee

3. **Accounts** - Bank accounts
   - AccountID (Primary Key, Identity)
   - AccountNumber (Unique)
   - CustomerID, AccountTypeID (Foreign Keys)
   - Balance, AvailableBalance, Status
   - OpenDate, CloseDate

4. **TransactionTypes** - Transaction type definitions
   - TransactionTypeID (Primary Key, Identity)
   - TypeCode (DEPOSIT, WITHDRAWAL, TRANSFER, FEE, INTEREST)
   - TypeName, IsDebit flag

5. **Transactions** - Transaction history
   - TransactionID (Primary Key, Identity, BigInt)
   - TransactionNumber (Unique)
   - AccountID, TransactionTypeID (Foreign Keys)
   - Amount, BalanceAfter, Description
   - RelatedAccountID (for transfers)
   - TransactionDate, Status

6. **Loans** - Loan accounts
   - LoanID (Primary Key, Identity)
   - LoanNumber (Unique)
   - CustomerID, AccountID (Foreign Keys)
   - LoanType (Personal, Mortgage, Auto, Business)
   - PrincipalAmount, InterestRate, TermMonths
   - MonthlyPayment, RemainingBalance
   - OriginationDate, MaturityDate, Status

**Stored Procedures:**
1. `GetCustomerAccounts` - Get all accounts for a customer
2. `ProcessTransaction` - Process deposits, withdrawals, transfers (with balance validation)
3. `GetAccountBalance` - Get account balance and transaction summary
4. `TransferFunds` - Transfer funds between accounts (atomic transaction)

**Indexes:**
- IX_Accounts_CustomerID
- IX_Accounts_AccountNumber (Unique)
- IX_Transactions_AccountID
- IX_Transactions_TransactionDate
- IX_Transactions_TransactionNumber (Unique)
- IX_Loans_CustomerID

## Troubleshooting

### Error: "Server name already exists"

**Problem:** SQL server name must be globally unique.

**Solution:** Change `sql_server_name` to something unique:
```hcl
sql_server_name = "mssql-server-${random_string.suffix.result}"
```

### Error: "sqlcmd: command not found"

**Problem:** sqlcmd is not installed.

**Solution:**
- Install sqlcmd (see Prerequisites)
- Or run SQL scripts manually using Azure Portal Query Editor
- Or use Azure CLI alternative (see below)

### SQL Scripts Not Running

**Problem:** Provisioner failed or sqlcmd not available.

**Solution:**
1. Verify credentials are correct
2. Ensure firewall allows Azure services (0.0.0.0)
3. Run SQL script manually:
   ```bash
   sqlcmd -S <server-fqdn> -d core-banking -U sqladmin -P "<password>" -i modules/mssql-server/sql/init.sql -v SCHEMA_NAME=Banking
   ```

### Error: "Login failed"

**Solution:**
- Verify firewall rules allow Azure services (0.0.0.0)
- Check username/password
- Ensure server is accessible

### Alternative: Using Azure CLI Instead of sqlcmd

If sqlcmd is not available, you can use Azure CLI:

```hcl
provisioner "local-exec" {
  command = <<-EOT
    az sql db execute \
      --server-name ${azurerm_mssql_server.main.name} \
      --resource-group ${var.resource_group_name} \
      --database-name ${each.key} \
      --file-path ${path.module}/sql/init.sql
  EOT
}
```

**Note:** Azure CLI `az sql db execute` may have limitations. sqlcmd is more reliable.

## Security Best Practices

1. ✅ **Strong Passwords**: Use complex passwords (16+ characters)
2. ✅ **Random Passwords**: Use `random_password` resource
3. ✅ **Firewall Rules**: Restrict access, don't use 0.0.0.0/0 for production
4. ✅ **TLS 1.2**: Minimum TLS version enforced
5. ✅ **Sensitive Variables**: Mark passwords as sensitive
6. ✅ **Key Vault**: Store passwords in Azure Key Vault (advanced)

## Testing the Database

### Connect Using sqlcmd

```bash
sqlcmd -S <server-fqdn> -d core-banking -U sqladmin -P "<password>"
```

### Run Queries

```sql
-- Check schema exists
SELECT * FROM sys.schemas WHERE name = 'Banking'

-- Check tables
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Banking'

-- Check stored procedures
SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = 'Banking'

-- Test stored procedure - Get customer accounts
EXEC Banking.GetCustomerAccounts @CustomerID = 1

-- Test stored procedure - Get account balance
EXEC Banking.GetAccountBalance @AccountID = 1

-- View transactions
SELECT TOP 10 * FROM Banking.Transactions ORDER BY TransactionDate DESC
```

## Key Concepts Demonstrated

### 1. Module Structure

```hcl
module "mssql_server" {
  source = "./modules/mssql-server"
  # Pass variables
}
```

### 2. Variable Passing

```hcl
# Root variables → Module variables → Resources
databases = {
  "core-banking" = {
    schema_name = "Banking"  # Passed to SQL script
  }
}
```

### 3. SQL Script Execution

```hcl
null_resource "sql_init" {
  provisioner "local-exec" {
    command = "sqlcmd ... -v SCHEMA_NAME=${var.schema_name}"
  }
}
```

### 4. Conditional Execution

```hcl
for_each = var.run_sql_scripts ? var.databases : {}
```

## Next Steps

- Add more databases with different schemas
- Create additional stored procedures
- Add database users and roles (via SQL scripts)
- Implement database backups
- Add database auditing
- Create database alerts

## Summary

**Key Takeaways:**

1. **Azure Provider** creates MSSQL Server and databases
2. **null_resource** executes SQL scripts for SQL objects
3. **SQL Scripts** create schemas, tables, and stored procedures
4. **Variables** make the module configurable
5. **Module Structure** organizes database infrastructure
6. **Firewall Rules** control database access
7. **Idempotent Scripts** can run multiple times safely

This pattern demonstrates how to manage both infrastructure and database objects with Terraform!

