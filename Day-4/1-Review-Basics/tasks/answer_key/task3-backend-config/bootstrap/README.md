# Bootstrap: Create Storage Account for Terraform State

This directory contains a Terraform configuration to create the Azure Storage Account and Blob Container needed for Terraform remote state.

## Purpose

Before you can use remote state, you need to create the storage infrastructure. This bootstrap configuration creates:
- Resource Group for state storage
- Storage Account (globally unique name)
- Blob Container for state files

## Usage

### Step 1: Initialize Bootstrap

```bash
cd bootstrap
terraform init
```

### Step 2: Review Plan

```bash
terraform plan
```

**Expected Resources:**
- 1 Resource Group
- 1 Storage Account
- 1 Blob Container
- 1 Random String (for unique naming)

### Step 3: Apply Bootstrap

```bash
terraform apply
```

### Step 4: Get Storage Account Name

```bash
# Get the storage account name
terraform output -raw storage_account_name

# Save it for later use
terraform output -raw storage_account_name > ../storage_account_name.txt
```

### Step 5: Use Output in Backend Configuration

Copy the backend configuration from the output:

```bash
terraform output -raw backend_config
```

Or manually create `backend.tf` in your main Terraform project:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "<output-from-terraform-output>"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
```

## Important Notes

1. **Run this bootstrap ONCE** - Creates the storage infrastructure
2. **Keep this state** - Don't delete this bootstrap state (or you'll lose track of the storage account)
3. **Use outputs** - Copy the storage account name to your main Terraform backend configuration
4. **Don't commit** - This is infrastructure setup, not part of your main project

## Cleanup

If you need to destroy the storage account (be careful!):

```bash
# WARNING: This will delete your state storage!
# Make sure you've backed up any state files first
terraform destroy
```

## Next Steps

After creating the storage account:
1. Copy the storage account name from outputs
2. Create `backend.tf` in your main Terraform project
3. Initialize your main project: `terraform init`
4. Migrate state if needed

