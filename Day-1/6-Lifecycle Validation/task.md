# Task for step-6 - Lifecycle Rules

This module focuses on understanding and implementing Terraform lifecycle rules to control resource creation, updates, and destruction.

## Learning Objectives

By completing this task, you will learn:
- How to use `create_before_destroy` to minimize downtime during updates
- How to use `prevent_destroy` to protect critical resources
- How to use `ignore_changes` to prevent configuration drift
- How to create custom validation conditions with `precondition`
- How to test and verify lifecycle rule behavior

## Assignment Requirements

Using the resources created earlier, implement the lifecycle rules as below:

1. **create_before_destroy lifecycle** in the storage account and test it by updating the name of storage account. The newer resource should be created first and then the existing resource should be destroyed.
2. **prevent_destroy lifecycle** in the storage account and update the storage account name and apply the changes. What did you observe?
3. **ignore_changes lifecycle** in the resource group and update the resource group name, apply the changes, what did you observe?
4. **Create a custom condition** that prevents the creation of resources in the location "canada central". It should throw an error if we have used "canada central" as the resource location.

---

## Step-by-Step Instructions

### Prerequisites

Before starting, ensure you have:
- Terraform initialized in this directory
- Azure provider configured and authenticated
- Access to Azure subscription
- Basic understanding of Terraform resources

### Step 1: Review Current Configuration

1. **Open `main.tf`** and review the existing resources:
   - `azurerm_resource_group.example` - Resource group
   - `azurerm_storage_account.example` - Storage account(s) using `for_each`

2. **Check `variables.tf`** to understand available variables:
   - `location` - Default: "West Europe"
   - `allowed_locations` - List of allowed locations
   - `storage_account_name` - Set of storage account names

3. **Initialize Terraform** (if not already done):
   ```bash
   terraform init
   ```

4. **Apply the initial configuration**:
   ```bash
   terraform apply
   ```
   This creates the base resources we'll work with.

---

### Step 2: Implement create_before_destroy Lifecycle Rule

**Objective:** Configure the storage account to create a new resource before destroying the old one when the name changes.

#### Step 2.1: Add create_before_destroy to Storage Account

1. **Open `main.tf`** and locate the `azurerm_storage_account` resource.

2. **Add a lifecycle block** with `create_before_destroy = true`:
   ```hcl
   resource "azurerm_storage_account" "example" {
     for_each = var.storage_account_name
     name                     = each.value
     resource_group_name      = azurerm_resource_group.example.name
     location                 = azurerm_resource_group.example.location
     account_tier             = "Standard"
     account_replication_type = "GRS"

     tags = {
       environment = var.environment
     }

     lifecycle {
       create_before_destroy = true
     }
   }
   ```

3. **Save the file**.

#### Step 2.2: Test create_before_destroy Behavior

1. **Review the current storage account names** in `variables.tf`:
   ```hcl
   variable "storage_account_name" {
     type = set(string)
     default = [ "techtutorials11", "techtutorials12" ]
   }
   ```

2. **Create a `terraform.tfvars` file** (if it doesn't exist) and change one storage account name:
   ```hcl
   storage_account_name = ["techtutorials11", "techtutorials13"]
   ```
   **Note:** Storage account names must be globally unique. Choose names that don't exist.

3. **Run terraform plan** to see the behavior:
   ```bash
   terraform plan
   ```

4. **Observe the output:**
   - You should see: `+/-` (create before destroy) instead of `-/+` (destroy before create)
   - The plan shows: `# azurerm_storage_account.example["techtutorials12"] will be destroyed`
   - And: `# azurerm_storage_account.example["techtutorials13"] will be created`
   - The order indicates: **create first, then destroy**

5. **Apply the changes**:
   ```bash
   terraform apply
   ```

6. **Verify the behavior:**
   - Watch the apply output - the new storage account is created first
   - Then the old storage account is destroyed
   - Both resources exist briefly during the transition (no downtime)

**✅ Success Criteria:** The plan shows `+/-` (create before destroy) and the apply creates the new resource before destroying the old one.

---

### Step 3: Implement prevent_destroy Lifecycle Rule

**Objective:** Protect the storage account from accidental deletion.

#### Step 3.1: Add prevent_destroy to Storage Account

1. **Open `main.tf`** and update the storage account lifecycle block:
   ```hcl
   lifecycle {
     create_before_destroy = true
     prevent_destroy        = true
   }
   ```

2. **Save the file**.

#### Step 3.2: Test prevent_destroy Behavior

1. **Try to change the storage account name** (which requires replacement):
   - Update `terraform.tfvars`:
     ```hcl
     storage_account_name = ["techtutorials11", "techtutorials14"]
     ```

2. **Run terraform plan**:
   ```bash
   terraform plan
   ```

3. **Observe the error:**
   - You should see an error like:
     ```
     Error: Instance cannot be replaced
     
     Resource instance azurerm_storage_account.example["techtutorials11"] cannot be replaced because
     it has prevent_destroy set to true in its lifecycle block.
     ```
   - The plan fails because replacing the resource would destroy it

4. **Try to destroy the resource**:
   ```bash
   terraform destroy
   ```

5. **Observe the error:**
   - You should see an error preventing destruction:
     ```
     Error: Instance cannot be destroyed
     
     Resource instance azurerm_storage_account.example["..."] cannot be destroyed because
     it has prevent_destroy set to true in its lifecycle block.
     ```

**✅ Success Criteria:** Both `terraform plan` (for replacement) and `terraform destroy` fail with clear error messages indicating the resource cannot be destroyed.

**📝 Observation:** 
- `prevent_destroy` blocks both replacement (which requires destruction) and explicit destruction
- To actually destroy the resource, you must first remove `prevent_destroy = true` from the lifecycle block
- This is a safety mechanism to protect critical resources

---

### Step 4: Implement ignore_changes Lifecycle Rule

**Objective:** Prevent Terraform from managing specific resource attributes that may change outside of Terraform.

#### Step 4.1: Add ignore_changes to Resource Group

1. **Open `main.tf`** and locate the `azurerm_resource_group` resource.

2. **Add `ignore_changes` to the lifecycle block**:
   ```hcl
   resource "azurerm_resource_group" "example" {
     name     = "${var.environment}-resources"
     location = var.location
     tags = {
       environment = var.environment
     }

     lifecycle {
       create_before_destroy = true
       prevent_destroy = false
       ignore_changes = [name]
     }
   }
   ```

3. **Save the file**.

#### Step 4.2: Test ignore_changes Behavior

1. **Apply the current configuration** (if not already applied):
   ```bash
   terraform apply
   ```

2. **Manually change the resource group name** in Azure Portal:
   - Go to Azure Portal → Resource Groups
   - Find your resource group
   - Click "Rename" and change the name
   - **Note:** Actually, Azure doesn't allow renaming resource groups. Instead, let's test by changing the name in the configuration.

3. **Change the resource group name in the configuration**:
   - Update `main.tf`:
     ```hcl
     name = "${var.environment}-resources-updated"
     ```

4. **Run terraform plan**:
   ```bash
   terraform plan
   ```

5. **Observe the output:**
   - You should see: **No changes**
   - The plan shows: `No changes. Your infrastructure matches the configuration.`
   - Terraform ignores the name change because it's in `ignore_changes`

6. **Remove `ignore_changes` temporarily** to see the difference:
   ```hcl
   lifecycle {
     create_before_destroy = true
     prevent_destroy = false
     # ignore_changes = [name]  # Commented out
   }
   ```

7. **Run terraform plan again**:
   ```bash
   terraform plan
   ```

8. **Observe the difference:**
   - Now you should see: `# azurerm_resource_group.example must be replaced`
   - The plan shows the resource will be replaced because the name changed

9. **Restore `ignore_changes`**:
   ```hcl
   ignore_changes = [name]
   ```

**✅ Success Criteria:** 
- With `ignore_changes = [name]`, Terraform ignores name changes
- Without it, Terraform detects the drift and wants to replace the resource
- This prevents Terraform from reverting external changes

**📝 Observation:**
- `ignore_changes` tells Terraform: "Don't manage this attribute, let it drift"
- Useful for attributes that change outside Terraform (like auto-generated names, tags managed by policies, etc.)
- You can ignore multiple attributes: `ignore_changes = [name, tags]`
- Use `ignore_changes = all` to ignore all attribute changes (not recommended)

---

### Step 5: Create Custom Condition to Prevent "canada central" Location

**Objective:** Add a validation that prevents resources from being created in "canada central" location.

#### Step 5.1: Add Precondition to Resource Group

1. **Open `main.tf`** and locate the `azurerm_resource_group` resource.

2. **Add a `precondition` block** to the lifecycle:
   ```hcl
   resource "azurerm_resource_group" "example" {
     name     = "${var.environment}-resources"
     location = var.location
     tags = {
       environment = var.environment
     }

     lifecycle {
       create_before_destroy = true
       prevent_destroy = false
       ignore_changes = [name]
       
       precondition {
         condition     = var.location != "canada central"
         error_message = "Location 'canada central' is not allowed. Please use a different location."
       }
     }
   }
   ```

3. **Save the file**.

#### Step 5.2: Test with Invalid Location

1. **Create or update `terraform.tfvars`** with invalid location:
   ```hcl
   location = "canada central"
   ```

2. **Run terraform plan**:
   ```bash
   terraform plan
   ```

3. **Observe the error:**
   - You should see an error like:
     ```
     Error: Resource precondition failed
     
       on main.tf line X, in resource "azurerm_resource_group" "example":
       X:   precondition {
     
     Location 'canada central' is not allowed. Please use a different location.
     ```
   - The plan fails before creating any resources

#### Step 5.3: Test with Valid Location

1. **Update `terraform.tfvars`** with a valid location:
   ```hcl
   location = "West Europe"
   ```

2. **Run terraform plan**:
   ```bash
   terraform plan
   ```

3. **Observe the success:**
   - The plan should succeed without errors
   - Resources can be created normally

#### Step 5.4: Enhanced Precondition (Optional)

1. **Update the precondition** to use the `allowed_locations` list:
   ```hcl
   precondition {
     condition     = contains(var.allowed_locations, var.location)
     error_message = "Location '${var.location}' is not in the allowed locations list: ${join(", ", var.allowed_locations)}"
   }
   ```

2. **Test with a location not in the allowed list**:
   ```hcl
   location = "East US"
   ```

3. **Run terraform plan** - should fail with your custom error message

**✅ Success Criteria:**
- Using "canada central" fails with your custom error message
- Using a valid location succeeds
- The error message is clear and helpful

**📝 Observation:**
- `precondition` blocks are evaluated **before** resource creation/update
- If a precondition fails, Terraform stops and shows your error message
- You can have multiple `precondition` blocks - all must pass
- Preconditions are useful for enforcing business rules and validating inputs

---

## Final Configuration Summary

After completing all steps, your `main.tf` should look similar to this:

```hcl
resource "azurerm_resource_group" "example" {
  name     = "${var.environment}-resources"
  location = var.location
  tags = {
    environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy        = false
    ignore_changes         = [name]
    
    precondition {
      condition     = var.location != "canada central"
      error_message = "Location 'canada central' is not allowed. Please use a different location."
    }
  }
}

resource "azurerm_storage_account" "example" {
  for_each = var.storage_account_name
  name                     = each.value
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
    ignore_changes        = [account_replication_type]
    replace_triggered_by  = [azurerm_resource_group.example.id]
  }
}
```

---

## Verification Checklist

- [ ] `create_before_destroy` is implemented in storage account
- [ ] Plan shows `+/-` (create before destroy) when changing storage account name
- [ ] `prevent_destroy` is implemented in storage account
- [ ] Plan fails when trying to replace storage account
- [ ] `terraform destroy` fails for storage account
- [ ] `ignore_changes` is implemented in resource group for `name`
- [ ] Plan shows no changes when resource group name is modified
- [ ] Precondition prevents "canada central" location
- [ ] Plan fails with custom error message when using "canada central"
- [ ] Plan succeeds with valid location

---

## Key Concepts Learned

- **create_before_destroy**: Ensures zero-downtime updates by creating new resources before destroying old ones
- **prevent_destroy**: Protects critical resources from accidental deletion
- **ignore_changes**: Allows attributes to drift without Terraform managing them
- **precondition**: Validates conditions before resource creation/update, enforcing business rules

---

## Troubleshooting

### Issue: Plan shows `-/+` instead of `+/-`
**Solution:** Ensure `create_before_destroy = true` is in the lifecycle block

### Issue: Can't destroy resource even without prevent_destroy
**Solution:** Check if `prevent_destroy` is set elsewhere or if the resource is referenced by other resources

### Issue: Precondition not working
**Solution:** Verify the condition expression is correct and uses proper Terraform syntax

### Issue: ignore_changes not working
**Solution:** Ensure the attribute name matches exactly (case-sensitive) and is in the correct format

---

## Next Steps

After completing this task, you should:
- Understand when to use each lifecycle rule
- Know how to combine multiple lifecycle rules
- Be able to create custom validation conditions
- Understand the difference between `precondition` and `postcondition`

For more advanced exercises, see [EXERCISE.md](./EXERCISE.md).
