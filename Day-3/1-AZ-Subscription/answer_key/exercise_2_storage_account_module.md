# Exercise 2 Answer: Storage Account Module

## Solution: Complete Module Implementation

### Directory Structure
```
modules/storage-account/
├── main.tf
├── variables.tf
└── output.tf
```

### modules/storage-account/variables.tf

```hcl
variable "storage_account_name" {
  type        = string
  description = "The name of the storage account. Must be globally unique and 3-24 characters."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the storage account will be created."
}

variable "location" {
  type        = string
  description = "The Azure region where the storage account will be created."
}

variable "account_tier" {
  type        = string
  description = "The storage account tier. Options are 'Standard' or 'Premium'."
  default     = "Standard"
}

variable "account_replication_type" {
  type        = string
  description = "The replication type for the storage account. Options are 'LRS', 'GRS', 'RAGRS', 'ZRS', 'GZRS', 'RAGZRS'."
  default     = "LRS"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the storage account."
  default     = {}
}
```

### modules/storage-account/main.tf

```hcl
resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  tags = var.tags
}
```

### modules/storage-account/output.tf

```hcl
output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.main.id
}

output "primary_access_key" {
  description = "The primary access key for the storage account."
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location."
  value       = azurerm_storage_account.main.primary_blob_endpoint
}
```

### Root main.tf - Calling the Module

Add this to your root `main.tf`:

```hcl
module "storage_account" {
  source = "./modules/storage-account"

  storage_account_name    = "mystorage${random_id.storage_suffix.hex}"
  resource_group_name     = azurerm_resource_group.rg1.name
  location                = var.location
  account_tier            = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Optional: Generate unique suffix for storage account name
resource "random_id" "storage_suffix" {
  byte_length = 4
}
```

**Note:** Storage account names must be globally unique. Consider using `random_id` or a naming convention.

## Answers to Questions

### Why should `primary_access_key` be marked as sensitive?
- **Answer:** Access keys provide full access to the storage account. Marking them as sensitive prevents Terraform from displaying them in logs, plans, and outputs, reducing security risk.

### What happens if you don't provide optional variables?
- **Answer:** Terraform uses the default values specified in the variable definition. If no default is provided and the variable is not set, Terraform will error.

### How do you reference the storage account from other resources?
- **Answer:** Use `module.storage_account.storage_account_id` or other output values. For example:
  ```hcl
  resource "azurerm_storage_container" "example" {
    name                 = "container"
    storage_account_name = module.storage_account.storage_account_id
  }
  ```

## Testing

```bash
# Initialize
terraform init

# Plan
terraform plan

# Should show:
# + module.storage_account.azurerm_storage_account.main
```

