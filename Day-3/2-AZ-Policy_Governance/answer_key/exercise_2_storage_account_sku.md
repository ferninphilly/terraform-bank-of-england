# Exercise 2 Answer: Storage Account SKU Policy

## Solution: Complete Storage Account SKU Restriction Policy

### Step 1: Add Variable to variables.tf

```hcl
variable "allowed_storage_skus" {
  type        = list(string)
  description = "List of allowed storage account SKUs"
  default     = ["Standard_LRS", "Standard_GRS"]
}
```

### Step 2: Create Policy Definition in main.tf

```hcl
resource "azurerm_policy_definition" "storage_sku" {
  name         = "storage-account-sku"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed Storage Account SKU Policy"
  description  = "This policy restricts storage account SKUs to Standard_LRS and Standard_GRS only"

  policy_rule = jsonencode({
    if = {
      field = "Microsoft.Storage/storageAccounts/sku.name",
      notIn = var.allowed_storage_skus
    },
    then = {
      effect = "deny"
    }
  })
}
```

### Step 3: Create Policy Assignment

```hcl
resource "azurerm_subscription_policy_assignment" "storage_sku" {
  name                 = "storage-sku-assignment"
  policy_definition_id = azurerm_policy_definition.storage_sku.id
  subscription_id      = data.azurerm_subscription.current.id
}
```

### Step 4: Test with Compliant Storage Account

Create a test file `test-storage-compliant.tf`:

```hcl
resource "azurerm_storage_account" "test_compliant" {
  name                     = "testcompliant${random_id.storage_suffix.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"  # ✅ Compliant - Standard_LRS

  tags = {
    department = "IT"
    project    = "Test"
  }
}

resource "random_id" "storage_suffix" {
  byte_length = 4
}
```

**Expected Result:** Storage account should be created successfully.

### Step 5: Test with Non-Compliant Storage Account

Create a test file `test-storage-noncompliant.tf`:

```hcl
resource "azurerm_storage_account" "test_noncompliant" {
  name                     = "testnoncompliant${random_id.storage_suffix.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = "eastus"
  account_tier             = "Premium"  # ❌ Non-compliant - Premium_LRS not allowed
  account_replication_type = "LRS"

  tags = {
    department = "IT"
    project    = "Test"
  }
}
```

**Expected Result:** 
```bash
terraform plan
# Error: Policy violation - Storage account SKU not allowed
```

## Answers to Questions

### What field path is used for storage account SKU?
**Answer:** `Microsoft.Storage/storageAccounts/sku.name`
- Format: `Microsoft.<Provider>/<ResourceType>/<PropertyPath>`
- This checks the SKU name property of storage accounts

### How do you check if a value is in a list?
**Answer:** Use the `in` operator (or `notIn` for negation):
```hcl
notIn = var.allowed_storage_skus
```
This checks if the storage account SKU is NOT in the allowed list.

### What happens if you try to create a Premium storage account?
**Answer:** The policy will deny the creation with an error message indicating the SKU is not allowed. The resource will not be created.

## Testing Commands

```bash
# Initialize
terraform init

# Plan (should show policy assignment)
terraform plan

# Apply policies
terraform apply

# Test compliant storage account
terraform apply -target=azurerm_storage_account.test_compliant

# Test non-compliant (should fail)
terraform plan -target=azurerm_storage_account.test_noncompliant
```

## Complete Example

**variables.tf addition:**
```hcl
variable "allowed_storage_skus" {
  type        = list(string)
  description = "List of allowed storage account SKUs"
  default     = ["Standard_LRS", "Standard_GRS"]
}
```

**main.tf addition:**
```hcl
# Storage Account SKU Policy
resource "azurerm_policy_definition" "storage_sku" {
  name         = "storage-account-sku"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed Storage Account SKU Policy"

  policy_rule = jsonencode({
    if = {
      field = "Microsoft.Storage/storageAccounts/sku.name",
      notIn = var.allowed_storage_skus
    },
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "storage_sku" {
  name                 = "storage-sku-assignment"
  policy_definition_id = azurerm_policy_definition.storage_sku.id
  subscription_id      = data.azurerm_subscription.current.id
}
```

