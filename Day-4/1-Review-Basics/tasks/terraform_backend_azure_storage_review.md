# Step-by-Step Guide: Terraform Backend Configuration with Azure Storage

This comprehensive guide walks you through configuring Terraform to store state files in Azure Storage Account (blob container). This is essential for team collaboration, state locking, and secure state management.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Understanding Terraform State](#understanding-terraform-state)
3. [Why Use Remote State?](#why-use-remote-state)
4. [Understanding Azure Storage Backend](#understanding-azure-storage-backend)
5. [Step 1: Create Storage Account](#step-1-create-storage-account)
6. [Step 2: Create Blob Container](#step-2-create-blob-container)
7. [Step 3: Configure Backend in Terraform](#step-3-configure-backend-in-terraform)
8. [Step 4: Initialize Backend](#step-4-initialize-backend)
9. [Step 5: Migrate Existing State](#step-5-migrate-existing-state)
10. [Step 6: Verify Remote State](#step-6-verify-remote-state)
11. [Backend Configuration Options](#backend-configuration-options)
12. [Troubleshooting](#troubleshooting)
13. [Best Practices](#best-practices)

---

## Prerequisites

Before starting, ensure you have:
- Terraform installed (version >= 1.5.0)
- Azure CLI installed and configured
- An Azure subscription
- Authenticated to Azure (`az login --use-device-code`)
- Appropriate permissions to create Storage Accounts

---

## Understanding Terraform State

### What is Terraform State?

Terraform state is a file that tracks:
- **Which resources exist** - Maps your Terraform configuration to real Azure resources
- **Resource metadata** - IDs, attributes, dependencies
- **Resource relationships** - How resources are connected

**Default location**: `terraform.tfstate` (local file)

### Local State vs Remote State

**Local State** (`terraform.tfstate`):
- ❌ Stored on your local machine
- ❌ Not shared with team members
- ❌ No locking (concurrent changes cause conflicts)
- ❌ Risk of loss if machine fails
- ✅ Simple for solo projects

**Remote State** (Azure Storage):
- ✅ Stored securely in Azure
- ✅ Shared with team members
- ✅ State locking (prevents conflicts)
- ✅ Backed up and versioned
- ✅ Required for production

---

## Why Use Remote State?

### 1. **Team Collaboration**
- Multiple team members can work on the same infrastructure
- Everyone sees the same state
- No "works on my machine" issues

### 2. **State Locking**
- Prevents two people from modifying infrastructure simultaneously
- Azure Storage provides automatic locking
- Reduces risk of corruption or conflicts

### 3. **Security**
- State files may contain sensitive data
- Azure Storage provides encryption at rest
- Access control via Azure RBAC

### 4. **Backup and Recovery**
- Azure Storage provides versioning
- Can restore previous state versions
- Protects against accidental deletion

### 5. **CI/CD Integration**
- GitHub Actions can access remote state
- No need to manage state files in CI/CD
- Consistent state across environments

---

## Understanding Azure Storage Backend

### Azure Storage Account Components

When configuring Terraform backend with Azure, you need:

1. **Storage Account** - The Azure storage service
   - Name must be globally unique (lowercase, alphanumeric, 3-24 chars)
   - Contains blob containers

2. **Blob Container** - Container within storage account
   - Stores the actual state files
   - Like a folder for state files

3. **State File Key** - Path/filename for your state file
   - Example: `vm-review.terraform.tfstate`
   - Can organize by project/environment

### Backend Configuration Structure

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"        # Resource group name
    storage_account_name = "tfstatestorage"    # Storage account name (globally unique)
    container_name       = "tfstate"           # Blob container name
    key                  = "project.terraform.tfstate"  # State file name/path
  }
}
```

**Important**: Backend configuration cannot use variables! Values must be hardcoded or provided via:
- Command-line flags (`-backend-config`)
- Backend configuration file
- Environment variables

---

## Step 1: Create Storage Account

### Option 1: Using Azure CLI (Recommended)

```bash
# Set variables
RESOURCE_GROUP="tfstate-rg"
STORAGE_ACCOUNT="tfstatestorage$(openssl rand -hex 4)"  # Random suffix for uniqueness
LOCATION="eastus"

# Create resource group (if it doesn't exist)
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create storage account
az storage account create \
  --resource-group $RESOURCE_GROUP \
  --name $STORAGE_ACCOUNT \
  --sku Standard_LRS \
  --kind StorageV2 \
  --location $LOCATION \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2

echo "Storage account created: $STORAGE_ACCOUNT"
```

**Key Parameters:**
- `--sku Standard_LRS` - Locally redundant storage (cheapest option)
- `--kind StorageV2` - Latest storage account kind
- `--allow-blob-public-access false` - Security best practice
- `--min-tls-version TLS1_2` - Security requirement

### Option 2: Using Terraform (Bootstrap)

Create a bootstrap configuration to create the storage account:

**File: `bootstrap/main.tf`**

```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Generate random suffix for storage account name
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Resource Group for Terraform State
resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate-rg"
  location = "eastus"
}

# Storage Account for Terraform State
resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstatestorage${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  
  # Security settings
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
  
  tags = {
    Environment = "shared"
    Purpose     = "TerraformState"
    ManagedBy   = "Terraform"
  }
}

# Blob Container for Terraform State
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# Output storage account name
output "storage_account_name" {
  description = "Name of the storage account for Terraform state"
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "Name of the blob container"
  value       = azurerm_storage_container.tfstate.name
}
```

**Deploy bootstrap:**

```bash
cd bootstrap
terraform init
terraform plan
terraform apply

# Save the storage account name
terraform output -raw storage_account_name > ../storage_account_name.txt
```

---

## Step 2: Create Blob Container

If you didn't create the container in Step 1, create it now:

### Using Azure CLI

```bash
STORAGE_ACCOUNT="your-storage-account-name"
RESOURCE_GROUP="tfstate-rg"
CONTAINER_NAME="tfstate"

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP \
  --account-name $STORAGE_ACCOUNT \
  --query '[0].value' -o tsv)

# Create container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT \
  --account-key $STORAGE_KEY \
  --public-access off
```

### Using Azure Portal

1. Go to Azure Portal
2. Navigate to your Storage Account
3. Click **Containers** in the left menu
4. Click **+ Container**
5. Name: `tfstate`
6. Public access level: **Private**
7. Click **Create**

---

## Step 3: Configure Backend in Terraform

### Create Backend Configuration File

**File: `backend.tf`**

```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatestorage1234"  # Replace with your storage account name
    container_name       = "tfstate"
    key                  = "vm-review.terraform.tfstate"
  }
}
```

**Important Notes:**
- `storage_account_name` must match your actual storage account name
- `key` is the path/filename for your state file
- You can organize state files by project: `project1/terraform.tfstate`
- You can organize by environment: `dev/terraform.tfstate`, `prod/terraform.tfstate`

### Backend Configuration Options

**Full Configuration:**

```hcl
backend "azurerm" {
  resource_group_name  = "tfstate-rg"
  storage_account_name = "tfstatestorage1234"
  container_name       = "tfstate"
  key                  = "project.terraform.tfstate"
  
  # Optional: Use specific subscription
  subscription_id = "12345678-1234-1234-1234-123456789012"
  
  # Optional: Use specific tenant
  tenant_id = "87654321-4321-4321-4321-210987654321"
  
  # Optional: Use access key instead of authentication
  # access_key = "your-access-key"
  
  # Optional: Use SAS token
  # sas_token = "your-sas-token"
  
  # Optional: Use managed identity (when running on Azure)
  # use_azuread_auth = true
  
  # Optional: Enable snapshot
  # snapshot = true
}
```

**Minimal Configuration (uses Azure CLI authentication):**

```hcl
backend "azurerm" {
  resource_group_name  = "tfstate-rg"
  storage_account_name = "tfstatestorage1234"
  container_name       = "tfstate"
  key                  = "project.terraform.tfstate"
}
```

---

## Step 4: Initialize Backend

After configuring the backend, initialize Terraform:

```bash
# Initialize Terraform (will configure backend)
terraform init

# Expected output:
# Initializing the backend...
# 
# Successfully configured the backend "azurerm"! Terraform will automatically
# use this backend unless the backend configuration changes.
```

**What happens:**
1. Terraform connects to Azure Storage
2. Verifies storage account and container exist
3. Creates state file if it doesn't exist
4. Downloads existing state if it exists

### If Backend Already Has State

If the backend already contains a state file, Terraform will ask:

```
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the backend.
  Terraform will copy the existing state to the new backend.
  Do you want to copy the existing state to the new backend?
  Enter "yes" to copy and "no" to start with an empty state.
```

- Type `yes` to migrate existing state
- Type `no` to start fresh (will lose existing state!)

---

## Step 5: Migrate Existing State

If you already have a local state file and want to migrate to remote:

### Method 1: During Initialization

```bash
# Terraform will detect local state and offer to migrate
terraform init

# When prompted:
# Do you want to migrate all workspaces to "azurerm"?
# Enter "yes"
```

### Method 2: Manual Migration

```bash
# Initialize with backend
terraform init -migrate-state

# Or force migration
terraform init -migrate-state -force-copy
```

### Method 3: Using terraform state mv

```bash
# Initialize backend first
terraform init

# Pull remote state (if exists)
terraform state pull > remote.tfstate

# Push local state
terraform state push local.tfstate
```

---

## Step 6: Verify Remote State

### Check State Location

```bash
# Show backend configuration
terraform init

# Check if state is remote
terraform state list

# Pull state to view
terraform state pull
```

### Verify in Azure Portal

1. Go to Azure Portal
2. Navigate to your Storage Account
3. Click **Containers** > **tfstate**
4. You should see your state file: `vm-review.terraform.tfstate`

**Screenshot Location**: `screenshots/backend-storage-container.png`
*[Screenshot should show: Azure Portal Storage Account container with state file visible]*

### Test State Locking

State locking prevents concurrent modifications:

```bash
# Terminal 1: Start apply (will lock state)
terraform apply

# Terminal 2: Try to run plan (will wait for lock)
terraform plan
# Output: Error: Error acquiring the state lock
```

**Screenshot Location**: `screenshots/backend-state-lock.png`
*[Screenshot should show: Terraform error message about state lock]*

---

## Backend Configuration Options

### Option 1: Hardcoded Values (Simple)

```hcl
backend "azurerm" {
  resource_group_name  = "tfstate-rg"
  storage_account_name = "tfstatestorage1234"
  container_name       = "tfstate"
  key                  = "project.terraform.tfstate"
}
```

**Pros:** Simple, works immediately  
**Cons:** Can't use variables, hard to change

### Option 2: Partial Configuration (Flexible)

**backend.tf:**
```hcl
backend "azurerm" {
  # Only specify what's always the same
  resource_group_name = "tfstate-rg"
  container_name      = "tfstate"
  # storage_account_name and key provided via -backend-config
}
```

**Initialize with:**
```bash
terraform init \
  -backend-config="storage_account_name=tfstatestorage1234" \
  -backend-config="key=project.terraform.tfstate"
```

### Option 3: Backend Configuration File

**backend.hcl:**
```hcl
storage_account_name = "tfstatestorage1234"
key                  = "project.terraform.tfstate"
```

**Initialize with:**
```bash
terraform init -backend-config=backend.hcl
```

### Option 4: Environment Variables

```bash
export TF_BACKEND_STORAGE_ACCOUNT_NAME="tfstatestorage1234"
export TF_BACKEND_KEY="project.terraform.tfstate"

terraform init
```

---

## Troubleshooting

### Issue: "Storage account not found"

**Problem:** Storage account doesn't exist or name is wrong

**Solutions:**
1. **Verify storage account exists:**
   ```bash
   az storage account list --query "[].name" -o table
   ```

2. **Check resource group:**
   ```bash
   az storage account show \
     --name tfstatestorage1234 \
     --resource-group tfstate-rg
   ```

3. **Verify name spelling** - Storage account names are case-sensitive

### Issue: "Container not found"

**Problem:** Blob container doesn't exist

**Solutions:**
1. **Create container:**
   ```bash
   az storage container create \
     --name tfstate \
     --account-name tfstatestorage1234 \
     --account-key $(az storage account keys list --resource-group tfstate-rg --account-name tfstatestorage1234 --query '[0].value' -o tsv)
   ```

2. **Check container name** - Must match exactly

### Issue: "Access Denied" or "Authentication Failed"

**Problem:** No permissions to access storage account

**Solutions:**
1. **Verify authentication:**
   ```bash
   az account show
   az login
   ```

2. **Check permissions:**
   - Need "Storage Blob Data Contributor" role
   - Or "Contributor" role on storage account

3. **Use access key** (less secure, for testing):
   ```hcl
   backend "azurerm" {
     resource_group_name  = "tfstate-rg"
     storage_account_name = "tfstatestorage1234"
     container_name       = "tfstate"
     key                  = "project.terraform.tfstate"
     access_key           = "your-access-key"  # Not recommended for production
   }
   ```

### Issue: "State lock error"

**Problem:** Another process is using the state file

**Solutions:**
1. **Wait** - Other process will release lock when done
2. **Check for stuck locks:**
   ```bash
   terraform force-unlock <LOCK_ID>
   ```
3. **Verify no other Terraform processes running**

### Issue: "Backend initialization required"

**Problem:** Backend not initialized

**Solutions:**
```bash
terraform init
```

### Issue: "State file already exists"

**Problem:** State file exists in backend but you want to start fresh

**Solutions:**
1. **Backup existing state** (if needed):
   ```bash
   terraform state pull > backup.tfstate
   ```

2. **Remove state file from Azure:**
   - Azure Portal > Storage Account > Container > Delete file
   - Or use Azure CLI:
     ```bash
     az storage blob delete \
       --container-name tfstate \
       --name project.terraform.tfstate \
       --account-name tfstatestorage1234
     ```

3. **Re-initialize:**
   ```bash
   terraform init
   ```

---

## Best Practices

### 1. **Separate Storage Accounts per Environment**

**Recommended Structure:**
```
tfstate-rg-dev/
  └── tfstatestorage-dev/
      └── tfstate/
          └── project.terraform.tfstate

tfstate-rg-prod/
  └── tfstatestorage-prod/
      └── tfstate/
          └── project.terraform.tfstate
```

**Benefits:**
- Isolation between environments
- Different access controls
- Easier to manage

### 2. **Organize State Files by Project**

**Use different keys:**
```hcl
# Project 1
key = "project1/terraform.tfstate"

# Project 2
key = "project2/terraform.tfstate"

# Environment-specific
key = "dev/terraform.tfstate"
key = "prod/terraform.tfstate"
```

### 3. **Enable Storage Account Features**

**Enable versioning:**
```bash
az storage account blob-service-properties update \
  --account-name tfstatestorage1234 \
  --resource-group tfstate-rg \
  --enable-versioning true
```

**Enable soft delete:**
```bash
az storage account blob-service-properties update \
  --account-name tfstatestorage1234 \
  --resource-group tfstate-rg \
  --enable-delete-retention true \
  --delete-retention-days 30
```

### 4. **Secure Access**

- ✅ Use Azure AD authentication (not access keys)
- ✅ Enable storage account firewall
- ✅ Use private endpoints for production
- ✅ Enable encryption at rest
- ✅ Use RBAC for access control

### 5. **Backup Strategy**

- Enable blob versioning
- Regular backups of state files
- Store backups in separate storage account
- Document recovery procedures

### 6. **Naming Conventions**

**Storage Account:**
- Format: `tfstate<environment><random>`
- Example: `tfstatedev1234`, `tfstateprod5678`

**Container:**
- Use consistent name: `tfstate`

**State File Key:**
- Format: `<project>/<environment>.terraform.tfstate`
- Example: `webapp/dev.terraform.tfstate`, `webapp/prod.terraform.tfstate`

---

## Complete Example

### Directory Structure

```
project/
├── backend.tf          # Backend configuration
├── provider.tf        # Provider configuration
├── main.tf            # Main resources
├── variables.tf       # Variables
└── terraform.tfvars   # Variable values
```

### backend.tf

```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatestorage1234"  # Your storage account name
    container_name       = "tfstate"
    key                  = "vm-review.terraform.tfstate"
  }
}
```

### provider.tf

```hcl
provider "azurerm" {
  features {}
}
```

### Initialize and Use

```bash
# Initialize backend
terraform init

# Plan (uses remote state)
terraform plan

# Apply (uses remote state with locking)
terraform apply
```

---

## Summary

In this guide, you learned:
- ✅ What Terraform state is and why remote state matters
- ✅ How Azure Storage Account and Blob Containers work
- ✅ How to create storage account and container
- ✅ How to configure Terraform backend
- ✅ How to initialize and migrate state
- ✅ How to verify remote state is working
- ✅ Best practices for state management

**Key Takeaways:**
- Azure Storage Account = Storage service
- Blob Container = Container for state files
- State File Key = Path/filename for your state
- Remote state enables team collaboration and state locking
- Backend configuration cannot use variables (must be hardcoded or provided via flags)

**Next Steps:**
- Set up storage account for your projects
- Configure backend in your Terraform configurations
- Practice migrating state between local and remote
- Explore state organization strategies

---

## Quick Reference

### Create Storage Account
```bash
az storage account create \
  --resource-group tfstate-rg \
  --name tfstatestorage1234 \
  --sku Standard_LRS \
  --kind StorageV2
```

### Create Container
```bash
az storage container create \
  --name tfstate \
  --account-name tfstatestorage1234
```

### Backend Configuration
```hcl
backend "azurerm" {
  resource_group_name  = "tfstate-rg"
  storage_account_name = "tfstatestorage1234"
  container_name       = "tfstate"
  key                  = "project.terraform.tfstate"
}
```

### Initialize
```bash
terraform init
```

### Verify
```bash
terraform state list
terraform state pull
```

