# 📝 Terraform String Manipulation - Step-by-Step Guide

This guide will walk you through using Terraform functions for string manipulation, data transformation, and resource configuration. You'll learn how to use built-in functions to format names, combine data, validate inputs, and more.

## 📚 Learning Objectives

By the end of this guide, you will:
- Understand common Terraform string manipulation functions
- Know how to transform and format resource names
- Combine and merge data structures
- Validate inputs using functions
- Handle file operations and timestamps
- Apply functions in real-world scenarios

---

## 🎯 Prerequisites

Before starting, ensure you have:
- Terraform installed and configured
- Basic understanding of Terraform syntax
- Access to Azure subscription (for resource creation)
- Text editor ready for writing Terraform code

---

## 🔧 Terraform Console - Your Testing Playground

Before we start, let's learn how to test functions interactively using `terraform console`.

### Step 1: Open Terraform Console

1. **Open a terminal** in your project directory
2. **Run the console command:**
   ```bash
   terraform console
   ```
3. **You'll see a prompt:** `>`

### Step 2: Test Basic Functions

Try these commands in the console (type each and press Enter):

```hcl
# Convert to lowercase
lower("HELLO WORLD")
# Output: "hello world"

# Find maximum value
max(5, 12, 9)
# Output: 12

# Remove whitespace
trim("  hello  ")
# Output: "hello"

# Remove trailing newline
chomp("hello\n")
# Output: "hello"

# Reverse a list
reverse(["a", "b", "c"])
# Output: ["c", "b", "a"]
```

4. **Exit the console** when done:
   ```bash
   exit
   ```

**💡 Tip:** Use `terraform console` anytime to test functions before using them in your code!

---

## ✅ Exercise 1: Project Naming Convention

**Objective:** Transform project names to meet Azure naming requirements using `lower()` and `replace()`.

### Step 1.1: Understand the Requirements

Azure resource names often have requirements:
- Must be lowercase
- Spaces should be replaced with hyphens
- No special characters

**Input:** `"Project ALPHA Resource"`  
**Output:** `"project-alpha-resource"`

### Step 1.2: Create the Variable

1. **Open `variables.tf`** (create it if it doesn't exist)
2. **Add the project name variable:**
   ```terraform
   variable "project_name" {
     type        = string
     description = "Name of the project"
     default     = "Project ALPHA Resource"
   }
   ```

### Step 1.3: Create a Local with String Transformation

1. **Open `main.tf`** (or create it)
2. **Add a locals block** with the transformation:
   ```terraform
   locals {
     # Step 1: Convert to lowercase
     # Step 2: Replace spaces with hyphens
     formatted_name = lower(replace(var.project_name, " ", "-"))
   }
   ```

3. **Let's break this down:**
   - `var.project_name` - Gets the input value
   - `replace(..., " ", "-")` - Replaces spaces with hyphens
   - `lower(...)` - Converts everything to lowercase
   - Functions are evaluated from inside out

### Step 1.4: Use the Transformed Name

1. **Add a resource group** using the formatted name:
   ```terraform
   resource "azurerm_resource_group" "rg" {
     name     = "${local.formatted_name}-rg"
     location = "westus2"
   }
   ```

### Step 1.5: Add an Output

1. **Add an output** to see the result:
   ```terraform
   output "formatted_project_name" {
     value = local.formatted_name
   }
   ```

### Step 1.6: Test It

1. **Run terraform plan:**
   ```bash
   terraform init
   terraform plan
   ```

2. **Check the output** - you should see the formatted name

**✅ Checkpoint:** What would happen if you used `replace()` before `lower()`? Try it and see!

---

## ✅ Exercise 2: Resource Tagging with merge()

**Objective:** Combine default tags with environment-specific tags using `merge()`.

### Step 2.1: Understand the Scenario

You have:
- **Default tags** that apply to all resources
- **Environment tags** that are specific to each environment
- Need to **combine** them into one tag map

### Step 2.2: Create Tag Variables

1. **Add to `variables.tf`:**
   ```terraform
   variable "default_tags" {
     type = map(string)
     default = {
       company    = "TechCorp"
       managed_by = "terraform"
     }
   }

   variable "environment_tags" {
     type = map(string)
     default = {
       environment  = "production"
       cost_center  = "cc-123"
     }
   }
   ```

### Step 2.3: Merge the Tags

1. **Add to `locals` block in `main.tf`:**
   ```terraform
   locals {
     formatted_name = lower(replace(var.project_name, " ", "-"))
     
     # Merge default and environment tags
     # If keys overlap, environment_tags will override default_tags
     merged_tags = merge(var.default_tags, var.environment_tags)
   }
   ```

### Step 2.4: Apply Tags to Resource

1. **Update the resource group** to use merged tags:
   ```terraform
   resource "azurerm_resource_group" "rg" {
     name     = "${local.formatted_name}-rg"
     location = "westus2"

     tags = local.merged_tags
   }
   ```

### Step 2.5: Add Output

1. **Add output** to see merged tags:
   ```terraform
   output "merged_tags" {
     value = local.merged_tags
   }
   ```

### Step 2.6: Test It

1. **Run terraform plan:**
   ```bash
   terraform plan
   ```

2. **Check the output** - you should see all tags combined

**✅ Checkpoint:** What happens if both maps have the same key? Which value wins?

---

## ✅ Exercise 3: Storage Account Naming with substr()

**Objective:** Format storage account names to meet Azure's strict requirements using `substr()`.

### Step 3.1: Understand Azure Storage Account Requirements

Azure storage account names must:
- Be 3-24 characters long
- Contain only lowercase letters and numbers
- Be globally unique

### Step 3.2: Create Storage Account Name Variable

1. **Add to `variables.tf`:**
   ```terraform
   variable "storage_account_name" {
     type        = string
     description = "Storage account name to format"
     default     = "projectalphastorageaccount"
   }
   ```

### Step 3.3: Format the Name

1. **Add to `locals` block:**
   ```terraform
   locals {
     formatted_name = lower(replace(var.project_name, " ", "-"))
     merged_tags    = merge(var.default_tags, var.environment_tags)
     
     # Format storage account name:
     # 1. Convert to lowercase
     # 2. Take first 23 characters (to ensure < 24)
     # 3. Remove spaces
     # 4. Remove special characters
     storage_formatted = replace(
       replace(
         lower(substr(var.storage_account_name, 0, 23)),
         " ", ""
       ),
       "!", ""
     )
   }
   ```

**Breaking it down:**
- `substr(string, start, length)` - Extracts substring
  - `substr("hello", 0, 3)` = "hel"
  - Start at position 0, take 23 characters
- `lower()` - Converts to lowercase
- `replace()` - Removes unwanted characters

### Step 3.4: Use in Storage Account Resource

1. **Add storage account resource:**
   ```terraform
   resource "azurerm_storage_account" "example" {
     name                     = local.storage_formatted
     resource_group_name      = azurerm_resource_group.rg.name
     location                 = azurerm_resource_group.rg.location
     account_tier             = "Standard"
     account_replication_type = "GRS"

     tags = local.merged_tags
   }
   ```

### Step 3.5: Add Output

1. **Add output:**
   ```terraform
   output "storage_account_name" {
     value = azurerm_storage_account.example.name
   }
   ```

### Step 3.6: Test It

1. **Run terraform plan:**
   ```bash
   terraform plan
   ```

2. **Verify** the name meets requirements

**✅ Checkpoint:** What happens if the input name is shorter than 23 characters?

---

## ✅ Exercise 4: Network Security Group Rules with split() and join()

**Objective:** Transform comma-separated ports into formatted rules using `split()` and `join()`.

### Step 4.1: Understand the Task

**Input:** `"80,443,8080,3306"`  
**Output:** List of port objects for NSG rules

### Step 4.2: Create Port Variable

1. **Add to `variables.tf`:**
   ```terraform
   variable "allowed_ports" {
     type        = string
     description = "Comma-separated list of allowed ports"
     default     = "80,443,3306"
   }
   ```

### Step 4.3: Split and Transform

1. **Add to `locals` block:**
   ```terraform
   locals {
     formatted_name = lower(replace(var.project_name, " ", "-"))
     merged_tags    = merge(var.default_tags, var.environment_tags)
     storage_formatted = replace(
       replace(
         lower(substr(var.storage_account_name, 0, 23)),
         " ", ""
       ),
       "!", ""
     )
     
     # Split comma-separated string into list
     formatted_ports = split(",", var.allowed_ports)
     
     # Transform list into NSG rule objects
     nsg_rules = [
       for port in local.formatted_ports : {
         name        = "port-${port}"
         port        = port
         description = "Allowed traffic on port: ${port}"
       }
     ]
   }
   ```

**Understanding the code:**
- `split(delimiter, string)` - Splits string into list
  - `split(",", "80,443")` = `["80", "443"]`
- `for` expression - Transforms each element
- String interpolation - `${port}` inserts the port number

### Step 4.4: Create NSG Resource with Dynamic Rules

1. **Add Network Security Group:**
   ```terraform
   resource "azurerm_network_security_group" "example" {
     name                = "${local.formatted_name}-nsg"
     location            = azurerm_resource_group.rg.location
     resource_group_name = azurerm_resource_group.rg.name

     # Dynamic block creates multiple security_rule blocks
     dynamic "security_rule" {
       for_each = local.nsg_rules
       content {
         name                       = security_rule.value.name
         priority                   = 100 + security_rule.key
         direction                  = "Inbound"
         access                     = "Allow"
         protocol                   = "Tcp"
         source_port_range          = "*"
         destination_port_range     = security_rule.value.port
         source_address_prefix      = "*"
         destination_address_prefix = "*"
         description                = security_rule.value.description
       }
     }
   }
   ```

### Step 4.5: Add Output

1. **Add output:**
   ```terraform
   output "nsg_rules" {
     value = local.nsg_rules
   }
   ```

### Step 4.6: Test It

1. **Run terraform plan:**
   ```bash
   terraform plan
   ```

2. **Verify** multiple security rules are created

**✅ Checkpoint:** How many security rules will be created if `allowed_ports = "80,443,3306"`?

---

## ✅ Exercise 5: Resource Lookup with lookup()

**Objective:** Use `lookup()` to get environment-specific configuration with fallback values.

### Step 5.1: Understand the Scenario

You have different VM sizes for different environments:
- `dev` → `"standard_D2s_v3"`
- `staging` → `"standard_D4s_v3"`
- `prod` → `"standard_D8s_v3"`

Need to look up the right size based on environment.

### Step 5.2: Create Variables

1. **Add to `variables.tf`:**
   ```terraform
   variable "environment" {
     type        = string
     description = "Environment name"
     default     = "dev"
   }

   variable "vm_sizes" {
     type = map(string)
     default = {
       dev     = "standard_D2s_v3"
       staging = "standard_D4s_v3"
       prod    = "standard_D8s_v3"
     }
   }
   ```

### Step 5.3: Implement Lookup

1. **Add to `locals` block:**
   ```terraform
   locals {
     # ... previous locals ...
     
     # Lookup VM size for environment, fallback to "dev" if not found
     vm_size = lookup(var.vm_sizes, var.environment, "standard_D2s_v3")
   }
   ```

**Understanding `lookup()`:**
- `lookup(map, key, default)` - Gets value from map
- If key exists → returns value
- If key doesn't exist → returns default value

### Step 5.4: Add Output

1. **Add output:**
   ```terraform
   output "vm_size" {
     value = local.vm_size
   }
   ```

### Step 5.5: Test Different Environments

1. **Test with dev:**
   ```bash
   terraform plan -var="environment=dev"
   ```

2. **Test with prod:**
   ```bash
   terraform plan -var="environment=prod"
   ```

3. **Test with invalid environment:**
   ```bash
   terraform plan -var="environment=invalid"
   # Should use fallback value
   ```

**✅ Checkpoint:** What happens if you use an environment that's not in the map?

---

## ✅ Exercise 6: VM Size Validation with length() and contains()

**Objective:** Validate VM size using `length()` and `contains()` functions.

### Step 6.1: Create Validated Variable

1. **Add to `variables.tf`:**
   ```terraform
   variable "vm_size" {
     type        = string
     description = "VM size"
     default     = "standard_D2s_v3"
     
     validation {
       # Check length is between 2 and 20 characters
       condition     = length(var.vm_size) >= 2 && length(var.vm_size) <= 20
       error_message = "The vm_size should be between 2 and 20 characters."
     }
     
     validation {
       # Check that it contains "standard"
       condition     = contains(split("_", var.vm_size), "standard")
       error_message = "The VM size should contain 'standard'."
     }
   }
   ```

**Understanding validations:**
- Multiple `validation` blocks = all must pass
- `length(string)` - Returns character count
- `contains(list, value)` - Checks if list contains value
- `split("_", string)` - Splits on underscore to check parts

### Step 6.2: Test Validations

1. **Test with valid size:**
   ```bash
   terraform plan -var="vm_size=standard_D2s_v3"
   # Should work
   ```

2. **Test with invalid length:**
   ```bash
   terraform plan -var="vm_size=x"
   # Should fail with length error
   ```

3. **Test without "standard":**
   ```bash
   terraform plan -var="vm_size=basic_A0"
   # Should fail with contains error
   ```

**✅ Checkpoint:** Can you have multiple validation blocks? What happens if one fails?

---

## ✅ Exercise 7: Backup Configuration with endswith() and sensitive

**Objective:** Validate backup names and handle sensitive credentials.

### Step 7.1: Create Variables with Validation

1. **Add to `variables.tf`:**
   ```terraform
   variable "backup_name" {
     type        = string
     description = "Backup name"
     default     = "daily_backup"
     
     validation {
       # Must end with "_backup"
       condition     = endswith(var.backup_name, "_backup")
       error_message = "Backup name should end with '_backup'."
     }
   }

   variable "credential" {
     type        = string
     description = "Backup credentials"
     default     = "xyz123"
     sensitive   = true  # Marks as sensitive
   }
   ```

**Understanding:**
- `endswith(string, suffix)` - Checks if string ends with suffix
- `sensitive = true` - Hides value in outputs and logs

### Step 7.2: Add Outputs

1. **Add outputs:**
   ```terraform
   output "backup_name" {
     value = var.backup_name
   }

   output "credential" {
     value     = var.credential
     sensitive = true  # Also mark output as sensitive
   }
   ```

### Step 7.3: Test It

1. **Test with valid backup name:**
   ```bash
   terraform plan -var="backup_name=my_backup"
   # Should work
   ```

2. **Test with invalid backup name:**
   ```bash
   terraform plan -var="backup_name=mybackup"
   # Should fail validation
   ```

3. **Check sensitive output:**
   ```bash
   terraform apply
   terraform output credential
   # Value should be hidden
   ```

**✅ Checkpoint:** Why is it important to mark credentials as sensitive?

---

## ✅ Exercise 8: File Path Processing

**Objective:** Work with file paths using `fileexists()` and `dirname()`.

### Step 8.1: Understand File Functions

- `fileexists(path)` - Checks if file exists (returns bool)
- `dirname(path)` - Gets directory name from path
- `basename(path)` - Gets filename from path

### Step 8.2: Create File Validation

1. **Add to `locals` block:**
   ```terraform
   locals {
     # ... previous locals ...
     
     # Check if main.tf exists
     main_tf_exists = fileexists("${path.module}/main.tf")
     
     # Get directory name
     config_dir = dirname("${path.module}/configs/main.tf")
   }
   ```

### Step 8.3: Add Outputs

1. **Add outputs:**
   ```terraform
   output "file_exists" {
     value = local.main_tf_exists
   }

   output "config_directory" {
     value = local.config_dir
   }
   ```

**💡 Note:** File functions are limited in Terraform. They work at plan time, not apply time.

---

## ✅ Exercise 9: Resource Set Management with toset() and concat()

**Objective:** Combine lists and remove duplicates using `toset()` and `concat()`.

### Step 9.1: Understand the Functions

- `concat(list1, list2)` - Combines two lists
- `toset(list)` - Converts list to set (removes duplicates)

### Step 9.2: Create Location Lists

1. **Add to `locals` block:**
   ```terraform
   locals {
     # ... previous locals ...
     
     # User-provided locations (may have duplicates)
     user_locations = ["eastus", "westus", "eastus"]
     
     # Default locations
     default_locations = ["centralus"]
     
     # Combine lists
     all_locations = concat(local.user_locations, local.default_locations)
     # Result: ["eastus", "westus", "eastus", "centralus"]
     
     # Convert to set to remove duplicates
     unique_locations = toset(local.all_locations)
     # Result: ["eastus", "westus", "centralus"]
   }
   ```

### Step 9.3: Add Output

1. **Add output:**
   ```terraform
   output "unique_locations" {
     value = local.unique_locations
   }
   ```

### Step 9.4: Test It

1. **Run terraform plan:**
   ```bash
   terraform plan
   ```

2. **Check output** - should show unique locations only

**✅ Checkpoint:** What's the difference between a list and a set in Terraform?

---

## ✅ Exercise 10: Cost Calculation with abs() and max()

**Objective:** Process cost data using `abs()` and `max()` functions.

### Step 10.1: Understand the Functions

- `abs(number)` - Returns absolute value (removes negative sign)
- `max(numbers...)` - Returns the maximum value

### Step 10.2: Process Costs

1. **Add to `locals` block:**
   ```terraform
   locals {
     # ... previous locals ...
     
     # Monthly costs (some may be negative)
     monthly_costs = [-50, 100, 75, 200]
     
     # Convert all to positive values
     positive_costs = [
       for cost in local.monthly_costs : abs(cost)
     ]
     # Result: [50, 100, 75, 200]
     
     # Find maximum cost
     max_cost = max(local.positive_costs...)
     # The ... expands the list into arguments
     # Result: 200
   }
   ```

**Understanding `...`:**
- Expands a list into function arguments
- `max([1, 2, 3]...)` = `max(1, 2, 3)`

### Step 10.3: Add Outputs

1. **Add outputs:**
   ```terraform
   output "positive_costs" {
     value = local.positive_costs
   }

   output "max_cost" {
     value = local.max_cost
   }
   ```

### Step 10.4: Test It

1. **Run terraform plan:**
   ```bash
   terraform plan
   ```

2. **Verify** costs are processed correctly

**✅ Checkpoint:** Why do we need the `...` when using `max()` with a list?

---

## ✅ Exercise 11: Timestamp Management with timestamp() and formatdate()

**Objective:** Generate and format timestamps for different purposes.

### Step 11.1: Understand Timestamp Functions

- `timestamp()` - Returns current timestamp (RFC3339 format)
- `formatdate(format, timestamp)` - Formats timestamp

### Step 11.2: Generate Formatted Timestamps

1. **Add to `locals` block:**
   ```terraform
   locals {
     # ... previous locals ...
     
     # Get current timestamp
     current_time = timestamp()
     
     # Format for resource names: YYYYMMDD
     resource_name = formatdate("YYYYMMDD", local.current_time)
     # Example: "20241114"
     
     # Format for tags: DD-MM-YYYY
     tag_date = formatdate("DD-MM-YYYY", local.current_time)
     # Example: "14-11-2024"
   }
   ```

**Date format reference:**
- `YYYY` - 4-digit year
- `MM` - 2-digit month
- `DD` - 2-digit day
- `HH` - 2-digit hour
- `mm` - 2-digit minute
- `ss` - 2-digit second

### Step 11.3: Use in Resources

1. **Update resource group** to use timestamp:
   ```terraform
   resource "azurerm_resource_group" "rg" {
     name     = "${local.formatted_name}-${local.resource_name}-rg"
     location = "westus2"

     tags = merge(local.merged_tags, {
       created_date = local.tag_date
     })
   }
   ```

### Step 11.4: Add Outputs

1. **Add outputs:**
   ```terraform
   output "resource_name_timestamp" {
     value = local.resource_name
   }

   output "tag_date" {
     value = local.tag_date
   }
   ```

**✅ Checkpoint:** When is the timestamp evaluated - at plan time or apply time?

---

## ✅ Exercise 12: File Content Handling with file() and sensitive

**Objective:** Read file contents securely using `file()` and handle sensitive data.

### Step 12.1: Create a Config File

1. **Create `config.json`** in your project directory:
   ```json
   {
     "database": {
       "host": "db.example.com",
       "port": 5432
     },
     "api_key": "secret123"
   }
   ```

### Step 12.2: Read File Content

1. **Add to `locals` block:**
   ```terraform
   locals {
     # ... previous locals ...
     
     # Read file content and mark as sensitive
     config_content = sensitive(file("${path.module}/config.json"))
   }
   ```

**Understanding:**
- `file(path)` - Reads file content as string
- `sensitive()` - Marks value as sensitive
- `${path.module}` - Path to current module directory

### Step 12.3: Parse JSON Content

1. **Add to `locals` block:**
   ```terraform
   locals {
     # ... previous locals ...
     config_content = sensitive(file("${path.module}/config.json"))
     
     # Parse JSON (remove sensitive wrapper first)
     config_data = jsondecode(nonsensitive(local.config_content))
   }
   ```

**Understanding:**
- `jsondecode(string)` - Parses JSON string to object
- `nonsensitive(value)` - Removes sensitive marker (use carefully!)

### Step 12.4: Use Config Data

1. **Add output** (be careful with sensitive data):
   ```terraform
   output "config_loaded" {
     # Only output non-sensitive parts
     value = {
       database_host = local.config_data.database.host
       database_port = local.config_data.database.port
       # Don't output api_key!
     }
   }
   ```

### Step 12.5: Test It

1. **Run terraform plan:**
   ```bash
   terraform plan
   ```

2. **Verify** file is read correctly

**⚠️ Warning:** Be very careful with sensitive data. Never commit secrets to version control!

**✅ Checkpoint:** Why should you mark file contents as sensitive?

---

## 📊 Summary of Functions Covered

| Function | Purpose | Example |
|----------|---------|---------|
| `lower()` | Convert to lowercase | `lower("HELLO")` → `"hello"` |
| `replace()` | Replace substring | `replace("a-b", "-", "_")` → `"a_b"` |
| `substr()` | Extract substring | `substr("hello", 0, 3)` → `"hel"` |
| `split()` | Split string to list | `split(",", "a,b")` → `["a", "b"]` |
| `join()` | Join list to string | `join("-", ["a", "b"])` → `"a-b"` |
| `merge()` | Merge maps | `merge({a=1}, {b=2})` → `{a=1, b=2}` |
| `lookup()` | Get map value | `lookup({a=1}, "a", 0)` → `1` |
| `length()` | Get length | `length("hello")` → `5` |
| `contains()` | Check if contains | `contains([1,2], 1)` → `true` |
| `endswith()` | Check suffix | `endswith("file.txt", ".txt")` → `true` |
| `toset()` | Remove duplicates | `toset([1,1,2])` → `[1, 2]` |
| `concat()` | Combine lists | `concat([1], [2])` → `[1, 2]` |
| `abs()` | Absolute value | `abs(-5)` → `5` |
| `max()` | Maximum value | `max(1, 2, 3)` → `3` |
| `timestamp()` | Current time | `timestamp()` → `"2024-11-14T..."` |
| `formatdate()` | Format date | `formatdate("YYYY", ts)` → `"2024"` |
| `file()` | Read file | `file("config.json")` → file content |

---

## 🎓 Key Takeaways

1. **Function Composition:** You can nest functions: `lower(replace(...))`
2. **Function Evaluation:** Functions are evaluated from inside out
3. **Testing:** Use `terraform console` to test functions before using them
4. **Sensitive Data:** Always mark sensitive values with `sensitive = true`
5. **Validation:** Use `validation` blocks to enforce rules
6. **Error Messages:** Provide clear error messages in validations

---

## 🐛 Common Mistakes

1. **Forgetting function order** - `lower(replace(...))` vs `replace(lower(...))`
2. **Wrong function arguments** - Check function signatures
3. **Not handling edge cases** - Empty strings, null values, etc.
4. **Exposing sensitive data** - Forgetting to mark as sensitive
5. **File path issues** - Using wrong paths for `file()` function

---

## 💡 Practice Challenges

1. **Create a function** that formats Azure resource names:
   - Input: `"My Project Resource"`
   - Output: `"myprojectresource"` (no spaces, lowercase, max 24 chars)

2. **Combine multiple tag sources:**
   - Default tags, environment tags, and project-specific tags
   - Use `merge()` to combine all three

3. **Validate email format:**
   - Check if variable contains `@` and `.`
   - Use `contains()` and `strcontains()`

---

## 📚 Additional Resources

- [Terraform Function Documentation](https://developer.hashicorp.com/terraform/language/functions)
- [Terraform String Functions](https://developer.hashicorp.com/terraform/language/functions#string-functions)
- [Terraform Collection Functions](https://developer.hashicorp.com/terraform/language/functions#collection-functions)
- [Terraform Console](https://developer.hashicorp.com/terraform/cli/commands/console)

---

## ✅ Completion Checklist

Before completing this guide, verify:

- [ ] You've tested functions in `terraform console`
- [ ] You've implemented all 12 exercises
- [ ] You understand function composition
- [ ] You can validate inputs using functions
- [ ] You know how to handle sensitive data
- [ ] You can format strings for Azure resources
- [ ] You understand when to use each function

---

## 🎉 Congratulations!

You've mastered Terraform string manipulation and functions! You can now:
- Transform and format resource names
- Combine and merge data structures
- Validate inputs effectively
- Handle files and timestamps
- Work with sensitive data securely

Keep practicing and exploring more Terraform functions!

