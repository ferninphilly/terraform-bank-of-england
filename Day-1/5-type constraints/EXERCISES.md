# 🎯 Terraform Type Constraints - Hands-On Exercises

This exercise guide will help you understand and practice using different Terraform variable type constraints. You'll learn how to define, use, and validate variables with various types.

## 📚 Learning Objectives

By the end of these exercises, you will:
- Understand all Terraform variable type constraints
- Know when to use each type
- Be able to create and use variables with proper type constraints
- Understand how to access values from complex types (lists, maps, tuples, objects)
- Recognize and fix common type-related errors

---

## 🔍 Type Constraints Overview

Terraform supports the following type constraints:

| Type | Description | Example Use Case |
|------|-------------|------------------|
| `string` | Text values | Environment names, resource names |
| `number` | Numeric values | Disk sizes, port numbers, counts |
| `bool` | Boolean (true/false) | Feature flags, enable/disable settings |
| `list(type)` | Ordered collection | Allowed locations, VM sizes |
| `map(type)` | Key-value pairs | Tags, configuration maps |
| `tuple([...])` | Fixed-length list with specific types | Network config (IP, subnet, mask) |
| `object({...})` | Structured data with named fields | VM configuration object |

---

## ✅ Exercise 1: String Type Constraint

**Objective:** Understand and use string type variables.

### Task 1.1: Review Existing String Variable

1. **Open `variables.tf`** and locate the `environment` variable:
   ```terraform
   variable "environment" {
       type = string
       description = "the env type"
       default = "staging"
   }
   ```

2. **Check how it's used in `main.tf`:**
   - Find where `var.environment` is referenced
   - Notice it's used in resource names: `"${var.environment}-resources"`

### Task 1.2: Create a New String Variable

1. **Add a new string variable** to `variables.tf`:
   ```terraform
   variable "project_name" {
       type        = string
       description = "Name of the project"
       default     = "myproject"
   }
   ```

2. **Use it in `main.tf`** - Update the resource group name:
   ```terraform
   resource "azurerm_resource_group" "example" {
     name     = "${var.project_name}-${var.environment}-resources"
     location = var.allowed_locations[2]
   }
   ```

3. **Test it:**
   ```bash
   terraform plan
   ```

4. **Try an invalid value** (create `terraform.tfvars`):
   ```hcl
   project_name = 123  # This should fail!
   ```

5. **Run terraform plan** and observe the error:
   ```bash
   terraform plan
   # Expected error: Incorrect value type
   ```

**✅ Checkpoint:** What error message did you get? Why did it fail?

---

## ✅ Exercise 2: Number Type Constraint

**Objective:** Understand and use number type variables.

### Task 2.1: Review Existing Number Variable

1. **Locate the `storage_disk` variable** in `variables.tf`:
   ```terraform
   variable "storage_disk" {
       type = number
       description = "the storage disk size of os"
       default = 80
   }
   ```

2. **See how it's used** in `main.tf`:
   ```terraform
   disk_size_gb = var.storage_disk
   ```

### Task 2.2: Create and Test Number Variable

1. **Add a new number variable** for VM count:
   ```terraform
   variable "vm_count" {
       type        = number
       description = "Number of VMs to create"
       default     = 1
   }
   ```

2. **Test valid values** (create/update `terraform.tfvars`):
   ```hcl
   storage_disk = 128
   vm_count     = 2
   ```

3. **Test invalid values:**
   ```hcl
   storage_disk = "128"  # String instead of number - should fail!
   vm_count     = "two"  # String instead of number - should fail!
   ```

4. **Run terraform plan** for each test case and observe errors.

**✅ Checkpoint:** What happens when you use a string value for a number variable?

---

## ✅ Exercise 3: Boolean Type Constraint

**Objective:** Understand and use boolean type variables.

### Task 3.1: Review Existing Boolean Variable

1. **Locate the `is_delete` variable** in `variables.tf`:
   ```terraform
   variable "is_delete" {
     type = bool
     description = "the default behavior to os disk upon vm termination"
     default = true
   }
   ```

2. **See how it's used** in `main.tf`:
   ```terraform
   delete_os_disk_on_termination = var.is_delete
   ```

### Task 3.2: Create and Test Boolean Variable

1. **Add a new boolean variable** for enabling features:
   ```terraform
   variable "enable_monitoring" {
       type        = bool
       description = "Enable monitoring for resources"
       default     = false
   }
   ```

2. **Test valid boolean values** (in `terraform.tfvars`):
   ```hcl
   is_delete        = true
   enable_monitoring = false
   ```

3. **Test invalid values:**
   ```hcl
   is_delete = "true"   # String - should fail!
   is_delete = 1        # Number - should fail!
   is_delete = "yes"    # String - should fail!
   ```

**✅ Checkpoint:** What are the only two valid values for a boolean variable?

---

## ✅ Exercise 4: List Type Constraint

**Objective:** Understand and use list type variables.

### Task 4.1: Review Existing List Variables

1. **Locate `allowed_locations`** in `variables.tf`:
   ```terraform
   variable "allowed_locations" {
       type = list(string)
       description = "list of allowed locations"
       default = [ "West Europe", "North Europe" , "Western Europe" ]
   }
   ```

2. **See how it's accessed** in `main.tf`:
   ```terraform
   location = var.allowed_locations[2]  # Accessing element at index 2
   ```

3. **Locate `allowed_vm_sizes`**:
   ```terraform
   variable "allowed_vm_sizes" {
     type        = list(string)
     description = "Allowed VM sizes"
     default     = ["Standard_DS1_v2", "Standard_DS2_v2", "Standard_DS3_v2"]
   }
   ```

### Task 4.2: Practice with Lists

1. **Add a new list variable** for allowed ports:
   ```terraform
   variable "allowed_ports" {
       type        = list(number)
       description = "List of allowed port numbers"
       default     = [22, 80, 443, 3389]
   }
   ```

2. **Use list functions** - Add to `main.tf`:
   ```terraform
   # Try accessing list elements
   output "first_location" {
     value = var.allowed_locations[0]
   }
   
   output "vm_size_count" {
     value = length(var.allowed_vm_sizes)
   }
   
   output "all_locations" {
     value = var.allowed_locations
   }
   ```

3. **Test list access** - Try accessing invalid indices:
   ```terraform
   # This will cause a runtime error if index doesn't exist
   # location = var.allowed_locations[10]  # What happens?
   ```

4. **Test invalid list values** (in `terraform.tfvars`):
   ```hcl
   allowed_locations = "West Europe"  # String instead of list - should fail!
   allowed_locations = ["West Europe", 123]  # Mixed types - should fail!
   ```

**✅ Checkpoint:** 
- How do you access the first element of a list?
- How do you get the length of a list?
- What happens if you access an index that doesn't exist?

---

## ✅ Exercise 5: Map Type Constraint

**Objective:** Understand and use map type variables.

### Task 5.1: Review Existing Map Variable

1. **Locate `resource_tags`** in `variables.tf`:
   ```terraform
   variable "resource_tags" {
       type = map(string)
       description = "tags to apply to the resources"
       default = {
         "environment" = "staging"
         "managed_by" = "terraform"
         "department" = "devops"
       }
   }
   ```

2. **See how it's accessed** in `main.tf`:
   ```terraform
   tags = {
     environment = var.resource_tags["environment"]
     managed_by = var.resource_tags["managed_by"]
     department = var.resource_tags["department"]
   }
   ```

### Task 5.2: Practice with Maps

1. **Add a new map variable** for environment-specific settings:
   ```terraform
   variable "env_config" {
       type = map(string)
       description = "Environment-specific configuration"
       default = {
         "dev"  = "small"
         "prod" = "large"
       }
   }
   ```

2. **Use map functions** - Add to `main.tf`:
   ```terraform
   output "all_tags" {
     value = var.resource_tags
   }
   
   output "tag_keys" {
     value = keys(var.resource_tags)
   }
   
   output "tag_values" {
     value = values(var.resource_tags)
   }
   ```

3. **Test map access** - Try accessing non-existent keys:
   ```terraform
   # What happens if key doesn't exist?
   # value = var.resource_tags["nonexistent"]
   ```

4. **Test invalid map values** (in `terraform.tfvars`):
   ```hcl
   resource_tags = ["tag1", "tag2"]  # List instead of map - should fail!
   resource_tags = "environment=staging"  # String instead of map - should fail!
   ```

**✅ Checkpoint:**
- How do you access a value from a map?
- What happens if you access a key that doesn't exist?
- Can maps have different value types? (Hint: `map(string)` vs `map(number)`)

---

## ✅ Exercise 6: Tuple Type Constraint

**Objective:** Understand and use tuple type variables.

### Task 6.1: Review Existing Tuple Variable

1. **Locate `network_config`** in `variables.tf`:
   ```terraform
   variable "network_config" {
     type        = tuple([string, string, number])
     description = "Network configuration (VNET address, subnet address, subnet mask)"
     default     = ["10.0.0.0/16", "10.0.2.0", 24]
   }
   ```

2. **See how it's accessed** in `main.tf`:
   ```terraform
   address_space       = [element(var.network_config,0)]  # First element (string)
   address_prefixes   = ["${element(var.network_config, 1)}/${element(var.network_config, 2)}"]  # Second and third elements
   ```

### Task 6.2: Practice with Tuples

1. **Add a new tuple variable** for database configuration:
   ```terraform
   variable "db_config" {
       type        = tuple([string, number, bool])
       description = "Database config (name, port, ssl_enabled)"
       default     = ["mydb", 5432, true]
   }
   ```

2. **Use tuple elements** - Add to `main.tf`:
   ```terraform
   output "vnet_address" {
     value = element(var.network_config, 0)
   }
   
   output "subnet_mask" {
     value = element(var.network_config, 2)
   }
   ```

3. **Test invalid tuple values** (in `terraform.tfvars`):
   ```hcl
   network_config = ["10.0.0.0/16", "10.0.2.0"]  # Wrong length - should fail!
   network_config = ["10.0.0.0/16", "10.0.2.0", "24"]  # Wrong type for third element - should fail!
   network_config = [10, "10.0.2.0", 24]  # Wrong type for first element - should fail!
   ```

**✅ Checkpoint:**
- What makes a tuple different from a list?
- How many elements must a tuple have?
- Can you change the order of types in a tuple?

---

## ✅ Exercise 7: Object Type Constraint

**Objective:** Understand and use object type variables.

### Task 7.1: Review Existing Object Variable

1. **Locate `vm_config`** in `variables.tf`:
   ```terraform
   variable "vm_config" {
     type = object({
       size         = string
       publisher    = string
       offer        = string
       sku          = string
       version      = string
     })
     description = "Virtual machine configuration"
     default = {
       size         = "Standard_DS1_v2"
       publisher    = "Canonical"
       offer        = "0001-com-ubuntu-server-jammy"
       sku          = "22_04-lts"
       version      = "latest"
     }
   }
   ```

2. **See how it's accessed** in `main.tf`:
   ```terraform
   sku       = var.vm_config.sku
   version   = var.vm_config.version
   ```

### Task 7.2: Practice with Objects

1. **Add a new object variable** for storage configuration:
   ```terraform
   variable "storage_config" {
       type = object({
         account_tier             = string
         account_replication_type = string
         access_tier              = string
       })
       description = "Storage account configuration"
       default = {
         account_tier             = "Standard"
         account_replication_type = "LRS"
         access_tier              = "Hot"
       }
   }
   ```

2. **Use object properties** - Add to `main.tf`:
   ```terraform
   output "vm_size" {
     value = var.vm_config.size
   }
   
   output "vm_publisher" {
     value = var.vm_config.publisher
   }
   
   output "full_vm_config" {
     value = var.vm_config
   }
   ```

3. **Test invalid object values** (in `terraform.tfvars`):
   ```hcl
   vm_config = {
     size = "Standard_DS1_v2"
     # Missing required fields - should fail!
   }
   
   vm_config = {
     size      = "Standard_DS1_v2"
     publisher = "Canonical"
     offer     = "0001-com-ubuntu-server-jammy"
     sku       = "22_04-lts"
     version   = "latest"
     extra     = "field"  # Extra field - what happens?
   }
   
   vm_config = {
     size      = 123  # Wrong type - should fail!
     publisher = "Canonical"
     offer     = "0001-com-ubuntu-server-jammy"
     sku       = "22_04-lts"
     version   = "latest"
   }
   ```

**✅ Checkpoint:**
- How do you access properties of an object?
- What happens if you omit a required field?
- What happens if you add an extra field not defined in the type?

---

## 🎯 Exercise 8: Combined Type Practice

**Objective:** Use multiple types together in a real-world scenario.

### Task 8.1: Create a Comprehensive Configuration

1. **Create a new variable file** `app_config.tf` with:
   ```terraform
   variable "application_config" {
     type = object({
       app_name     = string
       environment  = string
       instance_count = number
       enabled      = bool
       regions      = list(string)
       tags         = map(string)
       network      = tuple([string, string, number])
       vm_settings  = object({
         size    = string
         os_type = string
       })
     })
     description = "Complete application configuration"
     default = {
       app_name      = "myapp"
       environment   = "dev"
       instance_count = 2
       enabled       = true
       regions       = ["West Europe", "North Europe"]
       tags = {
         "team" = "devops"
         "cost" = "development"
       }
       network      = ["10.0.0.0/16", "10.0.1.0", 24]
       vm_settings = {
         size    = "Standard_DS1_v2"
         os_type = "Linux"
       }
     }
   }
   ```

2. **Use the nested object** in `main.tf`:
   ```terraform
   output "app_instance_count" {
     value = var.application_config.instance_count
   }
   
   output "first_region" {
     value = var.application_config.regions[0]
   }
   
   output "team_tag" {
     value = var.application_config.tags["team"]
   }
   
   output "vm_size" {
     value = var.application_config.vm_settings.size
   }
   ```

3. **Test with terraform plan:**
   ```bash
   terraform plan
   ```

**✅ Checkpoint:** How do you access nested object properties?

---

## 🐛 Exercise 9: Common Type Errors and Fixes

**Objective:** Learn to identify and fix common type constraint errors.

### Task 9.1: Error Scenarios

For each scenario below:
1. Create the invalid configuration
2. Run `terraform validate` or `terraform plan`
3. Read the error message
4. Fix the error
5. Document what was wrong

#### Scenario 1: Wrong Type
```terraform
variable "port" {
  type = number
  default = "8080"  # ❌ String instead of number
}
```

**Fix:** Change default to `8080` (without quotes)

#### Scenario 2: Wrong List Element Type
```terraform
variable "ports" {
  type = list(number)
  default = [80, "443", 8080]  # ❌ Mixed types
}
```

**Fix:** Change to `[80, 443, 8080]` (all numbers)

#### Scenario 3: Missing Required Object Field
```terraform
variable "config" {
  type = object({
    name = string
    port = number
  })
  default = {
    name = "app"  # ❌ Missing 'port'
  }
}
```

**Fix:** Add `port = 8080` to default

#### Scenario 4: Wrong Tuple Length
```terraform
variable "network" {
  type = tuple([string, string, number])
  default = ["10.0.0.0/16", "10.0.1.0"]  # ❌ Only 2 elements, need 3
}
```

**Fix:** Add third element: `["10.0.0.0/16", "10.0.1.0", 24]`

#### Scenario 5: Wrong Map Value Type
```terraform
variable "settings" {
  type = map(string)
  default = {
    port = 8080  # ❌ Number instead of string
    name = "app"
  }
}
```

**Fix:** Change to `port = "8080"` or change type to `map(any)`

**✅ Checkpoint:** What are the most common type errors you encountered?

---

## 📊 Exercise 10: Type Validation Challenge

**Objective:** Test your understanding with a validation challenge.

### Challenge: Fix the Broken Configuration

1. **Create a file `broken.tf`** with these broken variables:
   ```terraform
   variable "broken_string" {
     type = string
     default = 12345  # ❌ Wrong type
   }
   
   variable "broken_list" {
     type = list(string)
     default = "single-string"  # ❌ Should be a list
   }
   
   variable "broken_map" {
     type = map(number)
     default = {
       "key1" = "value1"  # ❌ String instead of number
       "key2" = 42
     }
   }
   
   variable "broken_tuple" {
     type = tuple([string, number])
     default = ["text", "123", 456]  # ❌ Wrong length and type
   }
   
   variable "broken_object" {
     type = object({
       name = string
       count = number
     })
     default = {
       name = "test"
       # ❌ Missing 'count'
       extra = "field"  # ❌ Extra field
     }
   }
   ```

2. **Fix all the errors** and verify with:
   ```bash
   terraform validate
   terraform plan
   ```

3. **Document your fixes** - What did you change and why?

---

## 📝 Summary Checklist

Before completing these exercises, verify:

- [ ] You've created variables with all 7 type constraints
- [ ] You understand how to access list elements by index
- [ ] You understand how to access map values by key
- [ ] You understand how to access tuple elements
- [ ] You understand how to access object properties
- [ ] You can identify type errors from error messages
- [ ] You can fix common type constraint errors
- [ ] You've tested invalid values to see error messages
- [ ] You understand when to use each type

---

## 🎓 Key Takeaways

1. **Type constraints enforce data validation** - They prevent invalid values at plan time
2. **Lists are ordered** - Access elements by index `[0]`, `[1]`, etc.
3. **Maps are key-value pairs** - Access values by key `["key"]`
4. **Tuples have fixed length and types** - Each position has a specific type
5. **Objects have named fields** - Access properties with dot notation `.property`
6. **Type errors are caught early** - Terraform validates types before applying changes
7. **Use appropriate types** - Choose types that match your data structure

---

## 💡 Bonus Challenges

1. **Create a variable** that uses `map(object({...}))` - a map where each value is an object
2. **Create a variable** that uses `list(object({...}))` - a list of objects
3. **Create a variable** that uses `tuple([object({...}), string, number])` - a tuple with an object as the first element
4. **Use `for_each`** with a map variable to create multiple resources
5. **Use `count`** with a list variable to create multiple resources

---

## 📚 Additional Resources

- [Terraform Variable Types Documentation](https://developer.hashicorp.com/terraform/language/values/variables#type-constraints)
- [Terraform Type Constraints](https://developer.hashicorp.com/terraform/language/expressions/type-constraints)
- [Terraform Functions](https://developer.hashicorp.com/terraform/language/functions)

---

## ✅ Completion

Once you've completed all exercises and can confidently:
- Define variables with proper type constraints
- Access values from complex types
- Identify and fix type errors
- Choose appropriate types for your use cases

You've mastered Terraform type constraints! 🎉

