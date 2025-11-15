# 🔄 Terraform Lifecycle Rules - Step-by-Step Guide

This guide will walk you through implementing and testing Terraform lifecycle rules. You'll learn how to control resource creation, destruction, and updates using lifecycle blocks.

## 📚 Learning Objectives

By the end of this guide, you will:
- Understand what lifecycle rules are and when to use them
- Implement `create_before_destroy` to minimize downtime
- Use `prevent_destroy` to protect critical resources
- Apply `ignore_changes` to prevent unwanted updates
- Create custom validation conditions with `precondition` and `postcondition`
- Test each lifecycle rule to verify behavior

---

## 🎯 What are Lifecycle Rules?

Lifecycle rules are special blocks in Terraform that control **how** resources are created, updated, and destroyed. They don't change **what** resources are created, but rather **when** and **in what order** operations happen.

### Common Lifecycle Arguments:

| Argument | Purpose | Use Case |
|----------|---------|----------|
| `create_before_destroy` | Create new resource before destroying old one | Minimize downtime during updates |
| `prevent_destroy` | Block resource destruction | Protect critical resources |
| `ignore_changes` | Ignore changes to specific attributes | Prevent drift from external changes |
| `replace_triggered_by` | Force replacement when referenced resource changes | Maintain consistency |
| `precondition` | Validate before resource creation/update | Enforce business rules |
| `postcondition` | Validate after resource creation/update | Ensure resource state |

---

## ✅ Exercise 1: Understanding create_before_destroy

**Objective:** Learn how `create_before_destroy` minimizes downtime by creating new resources before destroying old ones.

### Step 1.1: Review Default Behavior (Destroy Before Create)

1. **Open `main.tf`** and locate the storage account resource:
   ```terraform
   resource "azurerm_storage_account" "example" {
     name                     = each.value
     resource_group_name      = azurerm_resource_group.example.name
     location                 = azurerm_resource_group.example.location
     account_tier             = "Standard"
     account_replication_type = "GRS"
   }
   ```

2. **Remove any existing lifecycle block** from the storage account (if present)

3. **Test default behavior:**
   ```bash
   # First, apply the current configuration
   terraform init
   terraform apply -auto-approve
   ```

4. **Now change the storage account name** in `main.tf`:
   ```terraform
   # Change the name (storage account names must be globally unique)
   # Update the variable or use a different name
   ```

5. **Run terraform plan** to see what will happen:
   ```bash
   terraform plan
   ```

6. **Observe the plan output:**
   - You should see: `# azurerm_storage_account.example["..."] must be replaced`
   - The plan shows: `-/+` (destroy and create)
   - **Default behavior:** Destroy first, then create

**⚠️ Problem:** This causes downtime! The old resource is destroyed before the new one exists.

---

### Step 1.2: Implement create_before_destroy

1. **Add lifecycle block** to the storage account in `main.tf`:
   ```terraform
   resource "azurerm_storage_account" "example" {
     name                     = each.value
     resource_group_name      = azurerm_resource_group.example.name
     location                 = azurerm_resource_group.example.location
     account_tier             = "Standard"
     account_replication_type = "GRS"

     lifecycle {
       create_before_destroy = true
     }
   }
   ```

2. **Run terraform plan** again:
   ```bash
   terraform plan
   ```

3. **Observe the difference:**
   - You should see: `+/-` (create and destroy)
   - The plan shows resources will be created FIRST, then destroyed
   - **Result:** No downtime! New resource exists before old one is removed

4. **Apply the changes:**
   ```bash
   terraform apply
   ```

5. **Watch the apply process:**
   - Notice the order: CREATE happens first, then DESTROY
   - Both resources exist briefly during the transition

**✅ Checkpoint:** Why is `create_before_destroy` important for production resources?

---

### Step 1.3: Test with Resource Name Change

1. **Update the storage account name** (use a new unique name):
   ```terraform
   # In variables.tf or terraform.tfvars, change one of the storage account names
   # Or modify the for_each directly
   ```

2. **Run terraform plan:**
   ```bash
   terraform plan
   ```

3. **Verify the lifecycle rule:**
   - Check that it shows `+/-` (create before destroy)
   - Confirm the new resource will be created first

4. **Apply and observe:**
   ```bash
   terraform apply
   ```

**📝 Note:** Storage account names must be globally unique, lowercase, and 3-24 characters. Use names like `mystorageaccount123` or `teststorage456`.

---

## ✅ Exercise 2: Understanding prevent_destroy

**Objective:** Learn how `prevent_destroy` protects critical resources from accidental deletion.

### Step 2.1: Implement prevent_destroy

1. **Add `prevent_destroy`** to the storage account lifecycle block:
   ```terraform
   resource "azurerm_storage_account" "example" {
     name                     = each.value
     resource_group_name      = azurerm_resource_group.example.name
     location                 = azurerm_resource_group.example.location
     account_tier             = "Standard"
     account_replication_type = "GRS"

     lifecycle {
       create_before_destroy = true
       prevent_destroy        = true  # Add this line
     }
   }
   ```

2. **Apply the configuration:**
   ```bash
   terraform apply -auto-approve
   ```

### Step 2.2: Test prevent_destroy Behavior

1. **Try to change the storage account name** (which would require replacement):
   ```terraform
   # Change the name to something new
   # This would normally destroy and recreate the resource
   ```

2. **Run terraform plan:**
   ```bash
   terraform plan
   ```

3. **Observe the error:**
   ```
   Error: Instance cannot be replaced
   
   Resource instance azurerm_storage_account.example["..."] cannot be replaced
   because its lifecycle.prevent_destroy attribute is set to true.
   ```

4. **Try to destroy the resource:**
   ```bash
   terraform destroy
   ```

5. **Observe the error:**
   - Terraform will refuse to destroy the resource
   - You'll see an error preventing destruction

**✅ Checkpoint:** What happens when you try to destroy a resource with `prevent_destroy = true`?

---

### Step 2.3: Understanding prevent_destroy Limitations

**Important Notes:**

1. **`prevent_destroy` only prevents Terraform from destroying:**
   - It does NOT prevent manual deletion in Azure Portal
   - It does NOT prevent deletion via Azure CLI
   - It only blocks Terraform operations

2. **When to use `prevent_destroy`:**
   - Production databases
   - Critical storage accounts with important data
   - Resources that are expensive or time-consuming to recreate
   - Resources that cannot be easily restored

3. **To actually destroy a protected resource:**
   - Temporarily set `prevent_destroy = false`
   - Run `terraform apply` to update the lifecycle block
   - Then run `terraform destroy`

**⚠️ Warning:** Use `prevent_destroy` carefully. It can prevent necessary updates that require resource replacement.

---

## ✅ Exercise 3: Understanding ignore_changes

**Objective:** Learn how `ignore_changes` prevents Terraform from updating resources when attributes change outside of Terraform.

### Step 3.1: The Problem - Configuration Drift

1. **Apply your current configuration:**
   ```bash
   terraform apply -auto-approve
   ```

2. **Manually change a resource in Azure Portal:**
   - Go to Azure Portal
   - Find your storage account
   - Change the `account_replication_type` from `GRS` to `LRS`
   - Save the changes

3. **Run terraform plan:**
   ```bash
   terraform plan
   ```

4. **Observe the drift:**
   - Terraform detects the change
   - Plan shows it will change `account_replication_type` back to `GRS`
   - This is called "configuration drift"

**Problem:** Sometimes you want external changes to persist, or you want to manage certain attributes manually.

---

### Step 3.2: Implement ignore_changes

1. **Add `ignore_changes`** to the storage account lifecycle block:
   ```terraform
   resource "azurerm_storage_account" "example" {
     name                     = each.value
     resource_group_name      = azurerm_resource_group.example.name
     location                 = azurerm_resource_group.example.location
     account_tier             = "Standard"
     account_replication_type = "GRS"

     lifecycle {
       create_before_destroy = true
       prevent_destroy       = false  # Set back to false for testing
       ignore_changes        = [account_replication_type]  # Add this line
     }
   }
   ```

2. **Apply the configuration:**
   ```bash
   terraform apply -auto-approve
   ```

3. **Manually change `account_replication_type` in Azure Portal again**

4. **Run terraform plan:**
   ```bash
   terraform plan
   ```

5. **Observe the difference:**
   - Terraform no longer detects the change to `account_replication_type`
   - The plan shows "No changes"
   - The manual change persists

**✅ Checkpoint:** What happens to attributes listed in `ignore_changes`?

---

### Step 3.3: Test ignore_changes with Resource Group

1. **Add `ignore_changes`** to the resource group:
   ```terraform
   resource "azurerm_resource_group" "example" {
     name     = "${var.environment}-resources"
     location = var.location
     
     tags = {
       environment = var.environment
     }

     lifecycle {
       ignore_changes = [name]  # Ignore changes to the name
     }
   }
   ```

2. **Try to change the resource group name** in `main.tf`:
   ```terraform
   name = "${var.environment}-new-resources"  # Changed name
   ```

3. **Run terraform plan:**
   ```bash
   terraform plan
   ```

4. **Observe the result:**
   - Terraform ignores the name change
   - The plan shows no changes to the resource group name
   - The resource keeps its original name

**⚠️ Important:** Be careful with `ignore_changes`. It can hide important configuration drift and make your infrastructure inconsistent.

---

### Step 3.4: Advanced ignore_changes - Multiple Attributes

1. **Ignore multiple attributes:**
   ```terraform
   lifecycle {
     ignore_changes = [
       account_replication_type,
       tags,
       account_tier
     ]
   }
   ```

2. **Ignore all tags:**
   ```terraform
   lifecycle {
     ignore_changes = [tags]
   }
   ```

3. **Ignore all attributes (use with extreme caution!):**
   ```terraform
   lifecycle {
     ignore_changes = all
   }
   ```

**⚠️ Warning:** Using `ignore_changes = all` effectively tells Terraform to stop managing the resource. Use only when absolutely necessary.

---

## ✅ Exercise 4: Understanding replace_triggered_by

**Objective:** Learn how `replace_triggered_by` forces resource replacement when referenced resources change.

### Step 4.1: Implement replace_triggered_by

1. **Add `replace_triggered_by`** to the storage account:
   ```terraform
   resource "azurerm_storage_account" "example" {
     name                     = each.value
     resource_group_name      = azurerm_resource_group.example.name
     location                 = azurerm_resource_group.example.location
     account_tier             = "Standard"
     account_replication_type = "GRS"

     lifecycle {
       create_before_destroy = true
       replace_triggered_by = [
         azurerm_resource_group.example.id  # Replace storage account if RG changes
       ]
     }
   }
   ```

2. **Change the resource group name:**
   ```terraform
   resource "azurerm_resource_group" "example" {
     name = "${var.environment}-new-resources"  # Changed name
     location = var.location
   }
   ```

3. **Run terraform plan:**
   ```bash
   terraform plan
   ```

4. **Observe the result:**
   - Storage accounts will be replaced when the resource group changes
   - This ensures consistency between related resources

**✅ Checkpoint:** When would you use `replace_triggered_by`?

---

## ✅ Exercise 5: Custom Validation with precondition

**Objective:** Learn how to create custom validation rules using `precondition` blocks.

### Step 5.1: Understand precondition

`precondition` blocks validate conditions **before** a resource is created or updated. If the condition is false, Terraform shows an error and stops.

### Step 5.2: Implement Location Validation

1. **Add a `precondition`** to the resource group to prevent "Canada Central":
   ```terraform
   resource "azurerm_resource_group" "example" {
     name     = "${var.environment}-resources"
     location = var.location
     
     tags = {
       environment = var.environment
     }

     lifecycle {
       precondition {
         condition     = var.location != "canada central"
         error_message = "Canada Central is not allowed as a resource location. Please choose a different location."
       }
     }
   }
   ```

2. **Test with invalid location** - Create `terraform.tfvars`:
   ```hcl
   location = "canada central"
   ```

3. **Run terraform plan:**
   ```bash
   terraform plan
   ```

4. **Observe the error:**
   ```
   Error: Resource precondition failed
   
   on main.tf line X:
     X: |   precondition {
     X: |     condition     = var.location != "canada central"
     X: |     error_message = "Canada Central is not allowed as a resource location..."
   
   Canada Central is not allowed as a resource location. Please choose a different location.
   ```

5. **Fix the location** in `terraform.tfvars`:
   ```hcl
   location = "West Europe"
   ```

6. **Run terraform plan again:**
   ```bash
   terraform plan
   ```

7. **Verify it works:**
   - Plan should succeed with a valid location

**✅ Checkpoint:** What happens when a `precondition` fails?

---

### Step 5.3: Implement Allowed Locations Validation

1. **Update the precondition** to check against allowed locations list:
   ```terraform
   resource "azurerm_resource_group" "example" {
     name     = "${var.environment}-resources"
     location = var.location
     
     tags = {
       environment = var.environment
     }

     lifecycle {
       precondition {
         condition     = contains(var.allowed_locations, var.location)
         error_message = "Location '${var.location}' is not in the allowed locations list: ${join(", ", var.allowed_locations)}"
       }
     }
   }
   ```

2. **Test with invalid location:**
   ```hcl
   # In terraform.tfvars
   location = "canada central"
   ```

3. **Run terraform plan:**
   ```bash
   terraform plan
   ```

4. **Observe the detailed error message:**
   - Shows which location was used
   - Lists all allowed locations
   - Provides clear guidance

5. **Test with valid location:**
   ```hcl
   location = "West Europe"  # This is in allowed_locations
   ```

6. **Run terraform plan:**
   ```bash
   terraform plan
   ```

7. **Verify success:**
   - Plan should succeed

---

### Step 5.4: Multiple Preconditions

1. **Add multiple preconditions** to validate multiple rules:
   ```terraform
   lifecycle {
     precondition {
       condition     = var.location != "canada central"
       error_message = "Canada Central is not allowed."
     }
     
     precondition {
       condition     = contains(var.allowed_locations, var.location)
       error_message = "Location must be in allowed locations list."
     }
     
     precondition {
       condition     = var.environment != ""
       error_message = "Environment cannot be empty."
     }
   }
   ```

2. **Test each condition** to verify they all work

**✅ Checkpoint:** Can you have multiple `precondition` blocks?

---

## ✅ Exercise 6: Custom Validation with postcondition

**Objective:** Learn how to validate resource state **after** creation using `postcondition`.

### Step 6.1: Understand postcondition

`postcondition` blocks validate conditions **after** a resource is created or updated. They're useful for ensuring the resource was created correctly.

### Step 6.2: Implement Storage Account Validation

1. **Add a `postcondition`** to validate storage account creation:
   ```terraform
   resource "azurerm_storage_account" "example" {
     name                     = each.value
     resource_group_name      = azurerm_resource_group.example.name
     location                 = azurerm_resource_group.example.location
     account_tier             = "Standard"
     account_replication_type = "GRS"

     lifecycle {
       create_before_destroy = true
       
       postcondition {
         condition     = self.account_tier == "Standard"
         error_message = "Storage account must be Standard tier."
       }
       
       postcondition {
         condition     = length(self.name) >= 3 && length(self.name) <= 24
         error_message = "Storage account name must be between 3 and 24 characters."
       }
     }
   }
   ```

2. **Apply the configuration:**
   ```bash
   terraform apply
   ```

3. **The postcondition validates** after the resource is created
   - If validation fails, Terraform reports an error
   - The resource may still exist, but Terraform marks it as tainted

**✅ Checkpoint:** What's the difference between `precondition` and `postcondition`?

---

## ✅ Exercise 7: Combining Multiple Lifecycle Rules

**Objective:** Learn how to combine multiple lifecycle rules effectively.

### Step 7.1: Complete Lifecycle Block Example

1. **Create a comprehensive lifecycle block** combining all rules:
   ```terraform
   resource "azurerm_storage_account" "example" {
     name                     = each.value
     resource_group_name      = azurerm_resource_group.example.name
     location                 = azurerm_resource_group.example.location
     account_tier             = "Standard"
     account_replication_type = "GRS"

     lifecycle {
       # Create new resource before destroying old one
       create_before_destroy = true
       
       # Prevent accidental destruction (set to false for testing)
       prevent_destroy = false
       
       # Ignore changes to these attributes
       ignore_changes = [
         account_replication_type,
         tags
       ]
       
       # Replace when resource group changes
       replace_triggered_by = [
         azurerm_resource_group.example.id
       ]
       
       # Validate before creation
       precondition {
         condition     = var.location != "canada central"
         error_message = "Canada Central is not allowed."
       }
       
       # Validate after creation
       postcondition {
         condition     = self.account_tier == "Standard"
         error_message = "Storage account must be Standard tier."
       }
     }
   }
   ```

2. **Test the complete lifecycle block:**
   ```bash
   terraform plan
   terraform apply
   ```

---

## 🎯 Exercise 8: Real-World Scenarios

### Scenario 1: Production Database Protection

**Requirement:** Protect a production database from accidental deletion.

```terraform
resource "azurerm_mssql_database" "production" {
  name      = "prod-db"
  server_id = azurerm_mssql_server.example.id

  lifecycle {
    prevent_destroy = true
    create_before_destroy = true
  }
}
```

### Scenario 2: Auto-Scaling Configuration

**Requirement:** Allow auto-scaling to change instance count, but manage other settings.

```terraform
resource "azurerm_virtual_machine_scale_set" "web" {
  name                = "web-vmss"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard_DS1_v2"
  instances           = 2

  lifecycle {
    ignore_changes = [instances]  # Allow auto-scaling to change this
  }
}
```

### Scenario 3: Environment-Specific Validation

**Requirement:** Only allow certain VM sizes in production.

```terraform
resource "azurerm_virtual_machine" "web" {
  name                  = "web-vm"
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  vm_size               = var.vm_size

  lifecycle {
    precondition {
      condition = var.environment != "prod" || contains(["Standard_DS2_v2", "Standard_DS3_v2"], var.vm_size)
      error_message = "Production environment requires Standard_DS2_v2 or Standard_DS3_v2 VM size."
    }
  }
}
```

---

## 📊 Summary Table

Fill out this table as you complete each exercise:

| Exercise | Lifecycle Rule | Purpose | Test Result |
|----------|---------------|---------|-------------|
| 1 | `create_before_destroy` | Minimize downtime | _____ |
| 2 | `prevent_destroy` | Protect resources | _____ |
| 3 | `ignore_changes` | Prevent drift | _____ |
| 4 | `replace_triggered_by` | Force replacement | _____ |
| 5 | `precondition` | Validate before | _____ |
| 6 | `postcondition` | Validate after | _____ |

---

## 🎓 Key Takeaways

1. **`create_before_destroy`** - Minimizes downtime by creating new resources before destroying old ones
2. **`prevent_destroy`** - Protects critical resources from accidental deletion (Terraform only)
3. **`ignore_changes`** - Prevents Terraform from managing specific attributes
4. **`replace_triggered_by`** - Forces replacement when referenced resources change
5. **`precondition`** - Validates conditions before resource creation/update
6. **`postcondition`** - Validates conditions after resource creation/update
7. **Combine rules** - You can use multiple lifecycle rules together
8. **Use carefully** - Lifecycle rules can have unintended consequences if misused

---

## 🐛 Common Mistakes to Avoid

1. **Setting `prevent_destroy = true` on everything** - Makes updates difficult
2. **Using `ignore_changes = all`** - Stops Terraform from managing the resource
3. **Forgetting that `prevent_destroy` only works in Terraform** - Doesn't prevent manual deletion
4. **Overusing `ignore_changes`** - Can hide important configuration drift
5. **Complex `precondition` logic** - Can be hard to debug when they fail

---

## 🔍 Verification Checklist

Before completing this guide, verify:

- [ ] You've implemented `create_before_destroy` and tested it
- [ ] You've implemented `prevent_destroy` and seen it block destruction
- [ ] You've implemented `ignore_changes` and verified drift is ignored
- [ ] You've implemented `replace_triggered_by` and tested it
- [ ] You've created `precondition` blocks that validate location
- [ ] You've created `postcondition` blocks that validate resource state
- [ ] You understand when to use each lifecycle rule
- [ ] You can combine multiple lifecycle rules effectively

---

## 💡 Bonus Challenges

1. **Create a lifecycle block** that:
   - Prevents destruction
   - Creates before destroying
   - Ignores tag changes
   - Validates location is not "canada central"

2. **Create a `precondition`** that validates:
   - Environment is not empty
   - Location is in allowed list
   - Storage account name is unique (hint: use `length()`)

3. **Create a `postcondition`** that validates:
   - Storage account tier is correct
   - Resource group name matches pattern
   - Tags contain required keys

---

## 📚 Additional Resources

- [Terraform Lifecycle Documentation](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle)
- [Terraform Preconditions and Postconditions](https://developer.hashicorp.com/terraform/language/expressions/custom-conditions)
- [Terraform Best Practices](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#best-practices)

---

## ✅ Completion

Once you've completed all exercises and can confidently:
- Implement lifecycle rules to control resource behavior
- Use preconditions and postconditions for validation
- Combine multiple lifecycle rules
- Understand when to use each rule

You've mastered Terraform lifecycle management! 🎉

