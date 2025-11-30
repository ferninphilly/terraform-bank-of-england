# Answer Key: Terraform Backend Configuration with Azure Storage

This directory contains complete examples and scripts for setting up Terraform remote state with Azure Storage Account.

## Directory Structure

```
task3-backend-config/
├── bootstrap/                    # Bootstrap configuration (creates storage)
│   ├── main.tf                  # Creates storage account and container
│   ├── variables.tf             # Bootstrap variables
│   └── README.md                # Bootstrap instructions
├── example-with-backend/         # Example Terraform project using backend
│   ├── backend.tf               # Backend configuration
│   ├── provider.tf              # Provider configuration
│   ├── main.tf                  # Example resources
│   └── output.tf                # Outputs
├── create_storage.sh             # Automated script to create storage
└── README.md                     # This file
```

## Quick Start

### Option 1: Using the Automated Script (Easiest)

```bash
# Run the script
./create_storage.sh

# The script will:
# - Create resource group
# - Create storage account (with random suffix)
# - Create blob container
# - Enable versioning and soft delete
# - Output backend configuration
```

### Option 2: Using Terraform Bootstrap

```bash
# Navigate to bootstrap directory
cd bootstrap

# Initialize and apply
terraform init
terraform plan
terraform apply

# Get storage account name
terraform output -raw storage_account_name

# Get backend configuration
terraform output -raw backend_config
```

### Option 3: Using Azure CLI Manually

```bash
# Set variables
RESOURCE_GROUP="tfstate-rg"
STORAGE_ACCOUNT="tfstatestorage$(openssl rand -hex 4)"
LOCATION="eastus"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account
az storage account create \
  --resource-group $RESOURCE_GROUP \
  --name $STORAGE_ACCOUNT \
  --sku Standard_LRS \
  --kind StorageV2

# Create container
az storage container create \
  --name tfstate \
  --account-name $STORAGE_ACCOUNT
```

## Using the Backend

### Step 1: Create backend.tf

Copy the backend configuration from the script output or bootstrap:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatestorage1234"  # Your storage account name
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
```

### Step 2: Initialize Backend

```bash
terraform init
```

**If you have existing local state:**
- Terraform will ask if you want to migrate
- Type `yes` to copy local state to remote
- Type `no` to start fresh (loses local state!)

### Step 3: Verify Remote State

```bash
# Check state location
terraform init

# List resources in state
terraform state list

# Pull state to view
terraform state pull
```

## Example Project

The `example-with-backend/` directory shows a complete Terraform project using remote state:

```bash
cd example-with-backend

# Update backend.tf with your storage account name
# Then initialize
terraform init

# Plan and apply
terraform plan
terraform apply
```

## What Gets Created

### Bootstrap Creates:
- ✅ Resource Group (`tfstate-rg`)
- ✅ Storage Account (`tfstatestorageXXXX` - random suffix)
- ✅ Blob Container (`tfstate`)
- ✅ Versioning enabled
- ✅ Soft delete enabled (30 days)

### Backend Configuration Uses:
- Storage Account for state storage
- Blob Container for organizing state files
- State file key for your specific project

## Key Concepts

### Storage Account
- Azure's storage service (like AWS S3)
- Globally unique name required
- Contains blob containers

### Blob Container
- Container within storage account
- Like a folder for files
- Default name: `tfstate`

### State File Key
- Path/filename for your state file
- Example: `terraform.tfstate`
- Can organize: `project1/terraform.tfstate`, `dev/terraform.tfstate`

## Backend Configuration Options

### Full Configuration

```hcl
backend "azurerm" {
  resource_group_name  = "tfstate-rg"
  storage_account_name = "tfstatestorage1234"
  container_name       = "tfstate"
  key                  = "terraform.tfstate"
}
```

### With Subscription/Tenant

```hcl
backend "azurerm" {
  resource_group_name  = "tfstate-rg"
  storage_account_name = "tfstatestorage1234"
  container_name       = "tfstate"
  key                  = "terraform.tfstate"
  subscription_id     = "12345678-1234-1234-1234-123456789012"
  tenant_id           = "87654321-4321-4321-4321-210987654321"
}
```

### Partial Configuration (with flags)

```hcl
backend "azurerm" {
  resource_group_name = "tfstate-rg"
  container_name      = "tfstate"
  # storage_account_name and key provided via -backend-config
}
```

Initialize with:
```bash
terraform init \
  -backend-config="storage_account_name=tfstatestorage1234" \
  -backend-config="key=terraform.tfstate"
```

## Troubleshooting

### Storage Account Not Found

```bash
# Verify storage account exists
az storage account list --query "[].name" -o table

# Check resource group
az storage account show \
  --name tfstatestorage1234 \
  --resource-group tfstate-rg
```

### Container Not Found

```bash
# Create container
az storage container create \
  --name tfstate \
  --account-name tfstatestorage1234 \
  --account-key $(az storage account keys list --resource-group tfstate-rg --account-name tfstatestorage1234 --query '[0].value' -o tsv)
```

### Access Denied

- Verify you're logged in: `az account show`
- Check you have "Storage Blob Data Contributor" role
- Or use access key (less secure, for testing)

### State Lock Error

```bash
# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

## Best Practices

1. **Separate Storage Accounts per Environment**
   - `tfstatestorage-dev`
   - `tfstatestorage-prod`

2. **Organize State Files by Project**
   - `project1/terraform.tfstate`
   - `project2/terraform.tfstate`

3. **Enable Security Features**
   - Versioning enabled
   - Soft delete enabled
   - Private access only
   - Encryption at rest

4. **Use Descriptive Keys**
   - `webapp/dev.terraform.tfstate`
   - `webapp/prod.terraform.tfstate`

## Next Steps

1. Create storage account using script or bootstrap
2. Configure backend in your Terraform projects
3. Initialize and migrate state
4. Verify remote state is working
5. Practice with multiple projects/environments

## Resources

- [Backend Configuration Guide](../../terraform_backend_azure_storage_review.md)
- [Azure Storage Documentation](https://docs.microsoft.com/azure/storage/)
- [Terraform Azure Backend](https://www.terraform.io/docs/language/settings/backends/azurerm.html)

