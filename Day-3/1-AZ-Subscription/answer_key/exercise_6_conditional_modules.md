# Exercise 6 Answer: Conditional Module Usage

## Solution: Conditional Module Creation

### Updated Root variables.tf

```hcl
variable "rgname" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type    = string
  default = "canadacentral"
}

variable "service_principal_name" {
  type = string
}

variable "keyvault_name" {
  type = string
}

variable "SUB_ID" {
  type = string
}

# New variable for conditional storage account
variable "create_storage_account" {
  type        = bool
  description = "Whether to create a storage account."
  default     = false
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account (required if create_storage_account is true)."
  default     = ""
}
```

### Updated Root main.tf

```hcl
# Conditional Storage Account Module
module "storage_account" {
  count = var.create_storage_account ? 1 : 0
  
  source = "./modules/storage-account"

  storage_account_name    = var.storage_account_name != "" ? var.storage_account_name : "storage${random_id.storage_suffix.hex}"
  resource_group_name     = azurerm_resource_group.rg1.name
  location                = var.location
  account_tier            = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Generate random suffix for storage account name (only if needed)
resource "random_id" "storage_suffix" {
  count       = var.create_storage_account ? 1 : 0
  byte_length = 4
}

# Example: Reference storage account conditionally
resource "azurerm_storage_container" "example" {
  count                = var.create_storage_account ? 1 : 0
  name                 = "container"
  storage_account_name = module.storage_account[0].storage_account_name
}
```

### Alternative: Using for_each for Multiple Storage Accounts

```hcl
variable "storage_accounts" {
  type = map(object({
    account_tier             = string
    account_replication_type = string
  }))
  description = "Map of storage accounts to create."
  default     = {}
}

module "storage_account" {
  for_each = var.storage_accounts
  
  source = "./modules/storage-account"

  storage_account_name    = each.key
  resource_group_name     = azurerm_resource_group.rg1.name
  location                = var.location
  account_tier            = each.value.account_tier
  account_replication_type = each.value.account_replication_type

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
```

### terraform.tfvars Examples

**Option 1: Single conditional storage account**
```hcl
create_storage_account = true
storage_account_name   = "mystorageaccount123"
```

**Option 2: Multiple storage accounts using for_each**
```hcl
storage_accounts = {
  "storage1" = {
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
  "storage2" = {
    account_tier             = "Standard"
    account_replication_type = "GRS"
  }
}
```

## Answers to Questions

### What's the difference between `count` and `for_each` for modules?
- **`count`:** 
  - Creates 0 to N instances based on a number
  - References: `module.name[0]`, `module.name[1]`
  - Good for: Simple on/off or fixed number of instances
  - Limitations: Can't remove items from middle of list without affecting others

- **`for_each`:** 
  - Creates instances based on a map or set
  - References: `module.name["key"]`
  - Good for: Dynamic number of instances, named resources
  - Benefits: Can add/remove individual items without affecting others

### How do you reference a module when using `count`?
- **Answer:** Use index notation: `module.name[index]`
  ```hcl
  # Create
  module "storage" {
    count = 1
    # ...
  }
  
  # Reference
  output "storage_id" {
    value = module.storage[0].storage_account_id
  }
  ```

### When would you want conditional module creation?
- **Answer:** 
  1. **Environment-specific resources:** Dev might not need expensive resources
  2. **Feature flags:** Enable/disable features based on configuration
  3. **Cost optimization:** Only create resources when needed
  4. **Testing:** Create minimal infrastructure for testing
  5. **Gradual rollout:** Add resources incrementally

## Testing Conditional Modules

### Test 1: Create Storage Account
```hcl
# terraform.tfvars
create_storage_account = true
storage_account_name   = "teststorage123"
```

```bash
terraform plan
# Should show: + module.storage_account[0]
```

### Test 2: Don't Create Storage Account
```hcl
# terraform.tfvars
create_storage_account = false
```

```bash
terraform plan
# Should show: No storage account resources
```

### Test 3: Multiple Storage Accounts
```hcl
# terraform.tfvars
storage_accounts = {
  "storage1" = { account_tier = "Standard", account_replication_type = "LRS" }
  "storage2" = { account_tier = "Standard", account_replication_type = "GRS" }
}
```

```bash
terraform plan
# Should show: + module.storage_account["storage1"]
#              + module.storage_account["storage2"]
```

## Common Patterns

### Pattern 1: Environment-Based Conditionals
```hcl
variable "environment" {
  type = string
}

module "expensive_resource" {
  count = var.environment == "prod" ? 1 : 0
  # ...
}
```

### Pattern 2: Feature Flags
```hcl
variable "enable_monitoring" {
  type    = bool
  default = false
}

module "monitoring" {
  count = var.enable_monitoring ? 1 : 0
  # ...
}
```

### Pattern 3: Conditional with Defaults
```hcl
module "backup" {
  count = var.enable_backup != null ? (var.enable_backup ? 1 : 0) : 1
  # Defaults to creating if not specified
}
```

## Best Practices

1. **Use Descriptive Variable Names:** `create_storage_account` is clearer than `create_sa`
2. **Provide Sensible Defaults:** Default to `false` for optional expensive resources
3. **Document Dependencies:** Note what happens when module is not created
4. **Handle References:** Use `try()` or conditionals when referencing optional modules
5. **Test Both Cases:** Always test with module created and not created

## Common Mistakes

### Mistake 1: Referencing Without Checking
```hcl
# ❌ Wrong - will fail if count = 0
output "storage_id" {
  value = module.storage_account.storage_account_id
}

# ✅ Correct
output "storage_id" {
  value = var.create_storage_account ? module.storage_account[0].storage_account_id : null
}
```

### Mistake 2: Using Wrong Index
```hcl
# ❌ Wrong - index 1 doesn't exist if only one instance
value = module.storage_account[1].storage_account_id

# ✅ Correct - use index 0 for first instance
value = module.storage_account[0].storage_account_id
```

### Mistake 3: Not Handling Optional Dependencies
```hcl
# ❌ Wrong - resource might not exist
resource "something" "example" {
  storage_id = module.storage_account[0].id
}

# ✅ Correct - make resource conditional too
resource "something" "example" {
  count      = var.create_storage_account ? 1 : 0
  storage_id = module.storage_account[0].id
}
```

