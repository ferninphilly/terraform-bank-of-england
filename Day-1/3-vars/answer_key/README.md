# Answer Key: Terraform Variables Exercise

This folder contains the complete solution for the variables exercise.

## 📁 File Structure

- **`main.tf`** - Main Terraform configuration with resources
- **`variables.tf`** - All variable definitions
- **`locals.tf`** - Local values (common_tags and resource_prefix)
- **`outputs.tf`** - Output definitions
- **`terraform.tfvars`** - Example variable values file

## ✅ Solution Overview

### 1. Variables Defined

All required variables are defined in `variables.tf`:

- **`subscription_id`** - Azure subscription ID (optional, can use environment variable)
- **`environment`** - Environment type with default value "staging"
- **`location`** - Azure region with default value "West Europe"

### 2. Locals Used

In `locals.tf`, we define:

- **`common_tags`** - Reusable tags for all resources:
  ```hcl
  common_tags = {
    environment = "dev"
    lob         = "banking"
    stage       = "alpha"
  }
  ```

- **`resource_prefix`** - Prefix for resource naming:
  ```hcl
  resource_prefix = "boe"
  ```

### 3. Variables Used in Resources

- **Resource Group**: Uses `var.location` and `local.resource_prefix`
- **Storage Account**: Uses `var.environment` in tags via `merge()`

### 4. Outputs Created

All outputs are in `outputs.tf`:
- Storage account name
- Environment value (for testing precedence)
- Resource group name and location
- Common tags

## 🎯 Exercise Solutions

### Exercise 1: Add a New Variable ✅

**Solution:** The `location` variable is defined in `variables.tf` and used in the resource group:

```hcl
# In variables.tf
variable "location" {
  type        = string
  description = "Azure region where resources will be created"
  default     = "West Europe"
}

# In main.tf
resource "azurerm_resource_group" "example" {
  name     = "${local.resource_prefix}-resources"
  location = var.location  # Using variable instead of hardcoded value
}
```

**Testing:** The `terraform.tfvars` file shows how to override it:
```hcl
location = "West Europe"
```

### Exercise 2: Create a Local Value ✅

**Solution:** The `resource_prefix` local is defined in `locals.tf` and used in resource names:

```hcl
# In locals.tf
locals {
  resource_prefix = "boe"
}

# In main.tf
resource "azurerm_resource_group" "example" {
  name = "${local.resource_prefix}-resources"  # Results in "boe-resources"
}

resource "azurerm_storage_account" "example" {
  name = "${local.resource_prefix}storage"  # Results in "boestorage"
}
```

### Exercise 3: Add an Output ✅

**Solution:** Multiple outputs are defined in `outputs.tf`, including:

```hcl
output "resource_group_location" {
  value       = azurerm_resource_group.example.location
  description = "The location of the resource group"
}
```

### Exercise 4: Test Precedence ✅

**How to test:**

1. **Default only:**
   ```bash
   rm -f terraform.tfvars
   unset TF_VAR_environment
   terraform plan
   # Result: environment = "staging" (default)
   ```

2. **terraform.tfvars:**
   ```bash
   echo 'environment = "demo"' > terraform.tfvars
   terraform plan
   # Result: environment = "demo"
   ```

3. **Environment variable:**
   ```bash
   export TF_VAR_environment="production"
   terraform plan
   # Result: environment = "production"
   ```

4. **Command-line flag:**
   ```bash
   terraform plan -var="environment=development"
   # Result: environment = "development" (highest precedence)
   ```

### Exercise 5: Use Ternary Operators ✅

**Solution:** The provider configuration demonstrates ternary operators, but you can also use them in resources. Here's how to implement the storage tier challenge:

**Step 1:** Add a variable for storage tier (optional):

```hcl
# In variables.tf
variable "storage_tier" {
  type        = string
  description = "Storage account tier (Standard or Premium)"
  default     = ""
}
```

**Step 2:** Use ternary operator in the storage account:

```hcl
# In main.tf
resource "azurerm_storage_account" "example" {
  name                     = "${local.resource_prefix}storage"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = var.storage_tier != "" ? var.storage_tier : "Standard"
  account_replication_type = var.environment == "production" ? "ZRS" : "LRS"
  # ... rest of configuration
}
```

**How it works:**
- `account_tier`: If `var.storage_tier` is provided (not empty), use it; otherwise default to "Standard"
- `account_replication_type`: If environment is "production", use "ZRS"; otherwise use "LRS"

**Testing:**
1. Without setting `storage_tier`: Uses "Standard" (default)
2. With `storage_tier = "Premium"` in terraform.tfvars: Uses "Premium"
3. With `environment = "production"`: Uses "ZRS" replication
4. With `environment = "staging"`: Uses "LRS" replication

## 🔍 Key Concepts Demonstrated

### Variable Precedence Order

1. **Command-line flags** (`-var`) - Highest
2. **Environment variables** (`TF_VAR_*`)
3. **terraform.tfvars** file
4. **Default values** - Lowest

### Using Locals

- Locals are computed values used within the configuration
- They're referenced with `local.name` (not `var.name`)
- Great for values that don't need user input
- Perfect for reusable configurations like tags

### Merging Tags

The storage account uses `merge()` to combine local tags with variable values:

```hcl
tags = merge(local.common_tags, {
  environment = var.environment  # Overrides the "dev" in common_tags
})
```

This results in:
```hcl
{
  environment = "demo"  # From var.environment (via terraform.tfvars)
  lob         = "banking"
  stage       = "alpha"
}
```

### Ternary Operators

Terraform supports **ternary operators** (conditional expressions) for setting values based on conditions. This is demonstrated in the provider configuration:

```hcl
provider "azurerm" {
  subscription_id = var.subscription_id != "" ? var.subscription_id : null
  features {}
}
```

**How it works:**
- **Syntax:** `condition ? true_value : false_value`
- **Condition:** `var.subscription_id != ""` - checks if the variable is not empty
- **If true:** Use `var.subscription_id` (the provided value)
- **If false:** Use `null` (which allows Terraform to use the environment variable `ARM_SUBSCRIPTION_ID` instead)

**Why use this?**
This pattern allows flexible authentication:
1. **Option 1:** Set `subscription_id` variable directly
2. **Option 2:** Leave it empty and use `ARM_SUBSCRIPTION_ID` environment variable
3. **Option 3:** Use Azure CLI authentication (no subscription_id needed)

**Other Ternary Operator Examples:**

```hcl
# Set a default value if variable is empty
name = var.name != "" ? var.name : "default-name"

# Choose between two locations
location = var.environment == "production" ? "East US" : "West Europe"

# Conditional resource naming
resource_name = var.use_prefix ? "${var.prefix}-resource" : "resource"
```

**Key Points:**
- Ternary operators evaluate the condition first
- Both the true and false values must be of compatible types
- Useful for providing fallback values or conditional logic
- Can be nested for more complex conditions (though `try()` or `coalesce()` might be cleaner)

## 🚀 Running the Solution

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Review the plan:**
   ```bash
   terraform plan
   ```

3. **Apply the configuration:**
   ```bash
   terraform apply
   ```

4. **View outputs:**
   ```bash
   terraform output
   ```

## 📝 Notes

- The `terraform.tfvars` file is automatically loaded by Terraform
- Variable values in `terraform.tfvars` override defaults
- Environment variables override `terraform.tfvars`
- Command-line flags override everything
- Locals are internal to the configuration and cannot be overridden

## 🎓 Learning Points

1. **Separation of Concerns**: Variables, locals, and outputs are in separate files for better organization
2. **Reusability**: Locals allow you to define values once and reuse them
3. **Flexibility**: Variables allow customization without changing code
4. **Precedence**: Understanding precedence helps you control which values are used
5. **Best Practices**: Using `merge()` for tags is a common pattern in Terraform

---

**Remember:** This is a reference solution. In practice, you may organize files differently based on your team's preferences and project size.

