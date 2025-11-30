# Complete Review: Terraform Variables

This comprehensive guide covers everything you need to know about Terraform variables, including types, hierarchies, precedence, validation, and best practices.

## Table of Contents
1. [Understanding Variables](#understanding-variables)
2. [Variable Types](#variable-types)
3. [Variable Declaration](#variable-declaration)
4. [Variable Hierarchy and Precedence](#variable-hierarchy-and-precedence)
5. [Assigning Values to Variables](#assigning-values-to-variables)
6. [Variable Validation](#variable-validation)
7. [Sensitive Variables](#sensitive-variables)
8. [Variable Scoping](#variable-scoping)
9. [Advanced Variable Patterns](#advanced-variable-patterns)
10. [Best Practices](#best-practices)
11. [Troubleshooting](#troubleshooting)

---

## Understanding Variables

### What are Variables?

**Variables** in Terraform are placeholders for values that can be provided when running Terraform. They make your configuration reusable, flexible, and maintainable.

**Key Concepts:**
- **Reusability**: Same configuration for different environments (dev, staging, prod)
- **Flexibility**: Change values without modifying code
- **Maintainability**: Centralize configuration values
- **Security**: Keep sensitive values out of code

### Why Use Variables?

**Without Variables:**
```hcl
resource "azurerm_resource_group" "main" {
  name     = "myproject-dev-rg"  # Hard-coded!
  location = "eastus"            # Hard-coded!
}
```

**With Variables:**
```hcl
variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "eastus"
}

resource "azurerm_resource_group" "main" {
  name     = "myproject-${var.environment}-rg"
  location = var.location
}
```

**Benefits:**
- ✅ Same code works for dev, staging, and prod
- ✅ Easy to change values
- ✅ Values can be validated
- ✅ Sensitive values can be marked

---

## Variable Types

Terraform supports several variable types. Understanding types is crucial for proper configuration.

### Primitive Types

#### 1. `string`
Text values (most common type).

```hcl
variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type        = string
  description = "Name of the project"
  default     = "myproject"
}
```

**Usage:**
```hcl
resource "azurerm_resource_group" "main" {
  name = "${var.project_name}-${var.environment}-rg"
}
```

#### 2. `number`
Numeric values (integers or floats).

```hcl
variable "vm_count" {
  type    = number
  default = 2
}

variable "disk_size_gb" {
  type    = number
  default = 100
}
```

**Usage:**
```hcl
resource "azurerm_managed_disk" "main" {
  count              = var.vm_count
  size               = var.disk_size_gb
  # ...
}
```

#### 3. `bool`
Boolean values (true or false).

```hcl
variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "create_backup" {
  type    = bool
  default = false
}
```

**Usage:**
```hcl
resource "azurerm_monitor_action_group" "main" {
  count = var.enable_monitoring ? 1 : 0
  # ...
}
```

### Collection Types

#### 4. `list(type)`
Ordered collection of values of the same type.

```hcl
variable "allowed_locations" {
  type    = list(string)
  default = ["eastus", "westus2", "westeurope"]
}

variable "subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
```

**Usage:**
```hcl
resource "azurerm_virtual_network" "main" {
  address_space = var.subnet_cidrs
  # ...
}

# Access by index
output "first_subnet" {
  value = var.subnet_cidrs[0]  # "10.0.1.0/24"
}
```

#### 5. `set(type)`
Unordered collection of unique values.

```hcl
variable "subnet_names" {
  type    = set(string)
  default = ["frontend", "backend", "database"]
}
```

**Usage:**
```hcl
resource "azurerm_subnet" "main" {
  for_each = var.subnet_names
  name     = each.value
  # ...
}
```

**Note:** Sets are automatically deduplicated and unordered.

#### 6. `map(type)`
Key-value pairs where all values are the same type.

```hcl
variable "common_tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Project     = "MyProject"
    ManagedBy   = "Terraform"
  }
}

variable "vm_sizes" {
  type = map(string)
  default = {
    "small"  = "Standard_B1s"
    "medium" = "Standard_B2s"
    "large"  = "Standard_D2s_v3"
  }
}
```

**Usage:**
```hcl
resource "azurerm_linux_virtual_machine" "main" {
  size = var.vm_sizes["medium"]  # "Standard_B2s"
  tags = var.common_tags
  # ...
}
```

### Complex Types

#### 7. `object({ ... })`
Structured data with named attributes of different types.

```hcl
variable "vm_config" {
  type = object({
    vm_size        = string
    admin_username = string
    disk_size_gb   = number
    enable_backup  = bool
  })
  
  default = {
    vm_size        = "Standard_B2s"
    admin_username = "azureuser"
    disk_size_gb   = 100
    enable_backup  = true
  }
}
```

**Usage:**
```hcl
resource "azurerm_linux_virtual_machine" "main" {
  size          = var.vm_config.vm_size
  admin_username = var.vm_config.admin_username
  # ...
}
```

#### 8. `tuple([type, type, ...])`
Ordered collection with specific types at each position.

```hcl
variable "network_config" {
  type = tuple([string, number, bool])
  # Position 0: string (vnet name)
  # Position 1: number (subnet count)
  # Position 2: bool (enable DDoS)
  
  default = ["myvnet", 3, true]
}
```

**Usage:**
```hcl
resource "azurerm_virtual_network" "main" {
  name = var.network_config[0]  # "myvnet"
  # ...
}
```

### Type Constraints

#### `any`
Accepts any type (use sparingly).

```hcl
variable "flexible_value" {
  type    = any
  default = "can be string, number, bool, etc."
}
```

#### `optional(type)`
Value can be omitted (null is allowed).

```hcl
variable "optional_tag" {
  type    = optional(string)
  default = null
}
```

#### `nullable(type)`
Value can be null.

```hcl
variable "nullable_string" {
  type    = nullable(string)
  default = null
}
```

---

## Variable Declaration

### Basic Syntax

```hcl
variable "variable_name" {
  type        = type_constraint
  default     = default_value
  description = "What this variable is for"
  sensitive   = true/false
  nullable    = true/false
  
  validation {
    condition     = validation_expression
    error_message = "Error message if validation fails"
  }
}
```

### Required Elements

**Minimum Declaration:**
```hcl
variable "name" {
  type = string
}
```

**Recommended Declaration:**
```hcl
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### Variable Attributes

#### `description`
Documents what the variable is for.

```hcl
variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}
```

**Best Practice:** Always include descriptions for clarity.

#### `type`
Specifies the variable's type (required if no default).

```hcl
variable "count" {
  type = number
}
```

#### `default`
Value used if not provided.

```hcl
variable "environment" {
  type    = string
  default = "dev"
}
```

**Note:** If no default is provided, the variable must be set via other methods.

#### `sensitive`
Hides variable value in logs and outputs.

```hcl
variable "admin_password" {
  type      = string
  sensitive = true
}
```

**Important:** Sensitive variables are still stored in state files (encrypt your state!).

#### `nullable`
Whether the variable can be null.

```hcl
variable "optional_config" {
  type     = nullable(string)
  default  = null
  nullable = true
}
```

---

## Variable Hierarchy and Precedence

Terraform uses a **precedence order** to determine which value to use when multiple sources provide values. Understanding this hierarchy is crucial!

### Precedence Order (Highest to Lowest)

1. **Command-line flags** (`-var` and `-var-file`)
2. **`.tfvars` files** (auto-loaded: `terraform.tfvars`, `*.auto.tfvars`)
3. **Environment variables** (`TF_VAR_*`)
4. **Default values** (in variable declaration)
5. **Interactive prompt** (if none of above)

### 1. Command-Line Flags (Highest Priority)

**Using `-var`:**
```bash
terraform apply -var="environment=prod" -var="location=westus2"
```

**Using `-var-file`:**
```bash
terraform apply -var-file="production.tfvars"
```

**Multiple `-var-file`:**
```bash
terraform apply -var-file="common.tfvars" -var-file="prod.tfvars"
# Later files override earlier ones
```

### 2. `.tfvars` Files

**Auto-loaded files** (in order):
1. `terraform.tfvars` (or `terraform.tfvars.json`)
2. `*.auto.tfvars` (alphabetically)

**Example:**
```bash
# Files in directory:
terraform.tfvars
common.auto.tfvars
prod.auto.tfvars

# Load order:
# 1. terraform.tfvars
# 2. common.auto.tfvars
# 3. prod.auto.tfvars (overrides common.auto.tfvars)
```

**Manual loading:**
```bash
terraform apply -var-file="custom.tfvars"
```

**`.tfvars` file format:**
```hcl
# terraform.tfvars
environment = "prod"
location    = "westus2"

vm_count = 3

common_tags = {
  Environment = "prod"
  Project     = "MyProject"
}
```

### 3. Environment Variables

Set variables using `TF_VAR_` prefix:

```bash
export TF_VAR_environment=prod
export TF_VAR_location=westus2
export TF_VAR_vm_count=3

terraform apply
```

**For complex types:**
```bash
# Map
export TF_VAR_common_tags='{"Environment":"prod","Project":"MyProject"}'

# List
export TF_VAR_subnet_cidrs='["10.0.1.0/24","10.0.2.0/24"]'
```

**Note:** Environment variables are useful for CI/CD pipelines.

### 4. Default Values

Used when no other value is provided:

```hcl
variable "environment" {
  type    = string
  default = "dev"  # Used if not set elsewhere
}
```

### 5. Interactive Prompt (Lowest Priority)

If no value is provided and no default exists, Terraform prompts:

```bash
$ terraform apply
var.environment
  Enter a value: prod
```

**Note:** Interactive prompts don't work well in automation.

### Precedence Example

**Files:**
```hcl
# variables.tf
variable "environment" {
  type    = string
  default = "dev"  # Lowest priority
}

# terraform.tfvars
environment = "staging"  # Medium priority

# Set via command line:
terraform apply -var="environment=prod"  # Highest priority
```

**Result:** `environment = "prod"` (command-line wins)

### Best Practices for Variable Precedence

1. **Use defaults** for common/development values
2. **Use `.tfvars`** for environment-specific configurations
3. **Use command-line** for one-off overrides
4. **Use environment variables** for CI/CD and secrets
5. **Never commit** `.tfvars` files with secrets (use `.gitignore`)

---

## Assigning Values to Variables

### Method 1: Default Values

```hcl
variable "location" {
  type    = string
  default = "eastus"
}
```

### Method 2: terraform.tfvars

```hcl
# terraform.tfvars
location = "westus2"
environment = "prod"
```

### Method 3: Command-Line

```bash
terraform apply -var="location=westus2"
terraform apply -var-file="prod.tfvars"
```

### Method 4: Environment Variables

```bash
export TF_VAR_location=westus2
terraform apply
```

### Method 5: Interactive Prompt

```bash
terraform apply
# Terraform will prompt for unset variables without defaults
```

### Complex Type Examples

**Map in .tfvars:**
```hcl
# terraform.tfvars
common_tags = {
  Environment = "prod"
  Project     = "MyProject"
  ManagedBy   = "Terraform"
}
```

**List in .tfvars:**
```hcl
# terraform.tfvars
subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]
```

**Object in .tfvars:**
```hcl
# terraform.tfvars
vm_config = {
  vm_size        = "Standard_B2s"
  admin_username = "azureuser"
  disk_size_gb   = 100
  enable_backup  = true
}
```

---

## Variable Validation

Validation rules ensure variables meet your requirements before Terraform runs.

### Basic Validation

```hcl
variable "environment" {
  type    = string
  default = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### Multiple Validations

```hcl
variable "vm_size" {
  type    = string
  default = "Standard_B1s"
  
  validation {
    condition     = can(regex("^Standard_[A-Z][0-9]+[a-z]*$", var.vm_size))
    error_message = "VM size must be a valid Azure VM size."
  }
  
  validation {
    condition     = length(var.vm_size) <= 20
    error_message = "VM size name must be 20 characters or less."
  }
}
```

### Common Validation Patterns

#### String Length

```hcl
variable "project_name" {
  type = string
  
  validation {
    condition     = length(var.project_name) >= 3 && length(var.project_name) <= 20
    error_message = "Project name must be between 3 and 20 characters."
  }
}
```

#### String Pattern (Regex)

```hcl
variable "storage_account_name" {
  type = string
  
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
  }
}
```

#### Number Range

```hcl
variable "vm_count" {
  type    = number
  default = 1
  
  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 10
    error_message = "VM count must be between 1 and 10."
  }
}
```

#### List/Set Length

```hcl
variable "subnets" {
  type = list(string)
  
  validation {
    condition     = length(var.subnets) >= 1 && length(var.subnets) <= 10
    error_message = "Must have between 1 and 10 subnets."
  }
}
```

#### Map Key Validation

```hcl
variable "environments" {
  type = map(string)
  
  validation {
    condition = alltrue([
      for k in keys(var.environments) : contains(["dev", "staging", "prod"], k)
    ])
    error_message = "Environment keys must be dev, staging, or prod."
  }
}
```

#### Object Property Validation

```hcl
variable "vm_config" {
  type = object({
    vm_size = string
    disk_size_gb = number
  })
  
  validation {
    condition     = var.vm_config.disk_size_gb >= 30 && var.vm_config.disk_size_gb <= 1024
    error_message = "Disk size must be between 30GB and 1024GB."
  }
}
```

### Validation Best Practices

1. ✅ **Validate early**: Catch errors before resources are created
2. ✅ **Clear error messages**: Tell users exactly what's wrong
3. ✅ **Validate all inputs**: Don't trust user input
4. ✅ **Use regex for patterns**: Validate formats (IPs, names, etc.)
5. ✅ **Validate ranges**: Ensure numbers are within acceptable limits

---

## Sensitive Variables

Sensitive variables hide values in logs and outputs, but **they are still stored in state files**.

### Declaring Sensitive Variables

```hcl
variable "admin_password" {
  type      = string
  sensitive = true
}

variable "api_key" {
  type      = string
  sensitive = true
  default   = null
}
```

### Using Sensitive Variables

```hcl
resource "azurerm_windows_virtual_machine" "main" {
  admin_password = var.admin_password  # Value is hidden in logs
  # ...
}
```

### Sensitive Output Behavior

**Normal Output:**
```hcl
output "password" {
  value = var.admin_password  # Shows actual value
}
```

**Sensitive Output:**
```hcl
output "password" {
  value     = var.admin_password
  sensitive = true  # Hides value in outputs
}
```

### What Sensitive Does (and Doesn't Do)

**✅ Does:**
- Hides values in `terraform plan` output
- Hides values in `terraform apply` output
- Hides values in console output
- Marks outputs as sensitive

**❌ Doesn't:**
- Encrypt values in state files
- Hide values in error messages
- Prevent values from being in logs
- Secure values in transit

**Important:** Always encrypt your Terraform state files and use proper secret management!

### Best Practices for Sensitive Variables

1. ✅ **Mark sensitive**: Use `sensitive = true` for passwords, keys, tokens
2. ✅ **Use secret managers**: Azure Key Vault, HashiCorp Vault, etc.
3. ✅ **Never commit**: Don't put sensitive values in `.tfvars` files
4. ✅ **Use environment variables**: For CI/CD pipelines
5. ✅ **Encrypt state**: Use remote state with encryption

---

## Variable Scoping

### Local Variables (Current Module)

Variables declared in `variables.tf` are available throughout the module:

```hcl
# variables.tf
variable "location" {
  type = string
}

# main.tf (same directory)
resource "azurerm_resource_group" "main" {
  location = var.location  # ✅ Accessible
}
```

### Module Variables

Variables passed to modules:

```hcl
# root module
module "network" {
  source = "./modules/network"
  
  location = var.location  # Pass variable to module
  environment = var.environment
}

# modules/network/variables.tf
variable "location" {
  type = string
}

variable "environment" {
  type = string
}
```

### Variable Shadowing

If a variable name conflicts, the most local scope wins:

```hcl
# root/variables.tf
variable "location" {
  default = "eastus"
}

# root/main.tf
module "network" {
  source = "./modules/network"
  location = var.location  # Uses root variable
}

# modules/network/variables.tf
variable "location" {
  default = "westus2"  # Different default
}

# modules/network/main.tf
resource "azurerm_resource_group" "main" {
  location = var.location  # Uses module's variable (from root's value)
}
```

---

## Advanced Variable Patterns

### 1. Conditional Defaults

```hcl
variable "environment" {
  type = string
}

locals {
  # Set default location based on environment
  default_location = var.environment == "prod" ? "westus2" : "eastus"
}

variable "location" {
  type    = string
  default = null
}

resource "azurerm_resource_group" "main" {
  location = var.location != null ? var.location : local.default_location
}
```

### 2. Variable Merging

```hcl
variable "common_tags" {
  type = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}

variable "environment_tags" {
  type = map(string)
  default = {
    Environment = "dev"
  }
}

locals {
  all_tags = merge(var.common_tags, var.environment_tags)
}
```

### 3. Variable Transformations

```hcl
variable "project_name" {
  type    = string
  default = "My Project"
}

locals {
  # Transform for Azure naming requirements
  normalized_name = lower(replace(var.project_name, " ", "-"))
  name_prefix     = "${local.normalized_name}-${var.environment}"
}
```

### 4. Variable Lookups

```hcl
variable "vm_size_tier" {
  type    = string
  default = "medium"
}

locals {
  vm_sizes = {
    "small"  = "Standard_B1s"
    "medium" = "Standard_B2s"
    "large"  = "Standard_D2s_v3"
  }
  
  vm_size = local.vm_sizes[var.vm_size_tier]
}
```

### 5. Variable Dependencies

```hcl
variable "create_public_ip" {
  type    = bool
  default = true
}

variable "public_ip_allocation" {
  type    = string
  default = "Static"
  
  validation {
    condition = var.create_public_ip == false || contains(["Static", "Dynamic"], var.public_ip_allocation)
    error_message = "public_ip_allocation must be Static or Dynamic when create_public_ip is true."
  }
}
```

---

## Best Practices

### 1. Always Use Type Constraints

✅ **Good:**
```hcl
variable "vm_count" {
  type    = number
  default = 1
}
```

❌ **Bad:**
```hcl
variable "vm_count" {
  default = 1  # No type constraint
}
```

### 2. Provide Descriptions

✅ **Good:**
```hcl
variable "location" {
  description = "Azure region where resources will be created (e.g., eastus, westus2)"
  type        = string
  default     = "eastus"
}
```

❌ **Bad:**
```hcl
variable "location" {
  type = string
}
```

### 3. Use Sensible Defaults

✅ **Good:**
```hcl
variable "environment" {
  type    = string
  default = "dev"  # Safe default for development
}
```

❌ **Bad:**
```hcl
variable "environment" {
  type = string
  # No default - requires input every time
}
```

### 4. Validate Inputs

✅ **Good:**
```hcl
variable "vm_count" {
  type    = number
  default = 1
  
  validation {
    condition     = var.vm_count > 0 && var.vm_count <= 10
    error_message = "VM count must be between 1 and 10."
  }
}
```

### 5. Mark Sensitive Variables

✅ **Good:**
```hcl
variable "admin_password" {
  type      = string
  sensitive = true
}
```

### 6. Use Meaningful Names

✅ **Good:**
```hcl
variable "resource_group_name" { }
variable "virtual_network_address_space" { }
```

❌ **Bad:**
```hcl
variable "rg" { }
variable "vnet" { }
```

### 7. Organize Variables

**Structure:**
```
variables.tf          # All variable declarations
terraform.tfvars      # Default values
prod.tfvars          # Production overrides
dev.tfvars           # Development overrides
```

### 8. Document Complex Types

```hcl
variable "vm_config" {
  type = object({
    vm_size        = string        # Azure VM size (e.g., Standard_B2s)
    admin_username = string        # Admin username (3-20 characters)
    disk_size_gb   = number        # OS disk size in GB (30-1024)
    enable_backup  = bool          # Whether to enable backup
  })
  
  description = <<-EOT
    Virtual machine configuration object.
    
    Example:
    {
      vm_size        = "Standard_B2s"
      admin_username = "azureuser"
      disk_size_gb   = 100
      enable_backup  = true
    }
  EOT
}
```

### 9. Use .gitignore for Sensitive Files

**.gitignore:**
```
*.tfvars
!terraform.tfvars.example
*.auto.tfvars
secrets.tfvars
```

### 10. Prefer Maps Over Lists for Named Resources

✅ **Good (for_each friendly):**
```hcl
variable "subnets" {
  type = map(object({
    address_prefix = string
  }))
}
```

❌ **Less Flexible:**
```hcl
variable "subnets" {
  type = list(object({
    name            = string
    address_prefix = string
  }))
}
```

---

## Troubleshooting

### Error: "Required variable not set"

**Problem:** Variable has no default and no value provided.

**Solution:**
- Provide value via `.tfvars` file
- Set environment variable: `export TF_VAR_variable_name=value`
- Use command-line: `terraform apply -var="variable_name=value"`
- Add default value in variable declaration

### Error: "Invalid value for variable"

**Problem:** Value doesn't match type constraint or validation.

**Solution:**
- Check variable type in `variables.tf`
- Verify value matches expected format
- Check validation rules
- Review error message for specific issue

### Error: "Variables not allowed here"

**Problem:** Using variable in wrong context (e.g., in `backend` block).

**Solution:**
- Some blocks don't support variables (like `backend`)
- Use `-backend-config` flags instead
- Or use partial configuration

### Variable Not Taking Expected Value

**Problem:** Precedence issue - wrong value being used.

**Solution:**
1. Check precedence order:
   - Command-line (`-var`) overrides everything
   - `.tfvars` files override defaults
   - Environment variables override defaults
2. Check for multiple `.tfvars` files
3. Verify no conflicting values
4. Use `terraform console` to check variable values:
   ```bash
   terraform console
   > var.environment
   ```

### Sensitive Variable Showing in Output

**Problem:** Sensitive variable value is visible.

**Solution:**
- Mark variable as sensitive: `sensitive = true`
- Mark output as sensitive: `sensitive = true`
- Remember: values still in state file (encrypt state!)

### Type Mismatch Errors

**Problem:** Value type doesn't match variable type.

**Solution:**
- Check variable type declaration
- Verify value format in `.tfvars`
- For complex types, ensure structure matches exactly
- Use `terraform validate` to catch early

---

## Summary

**Key Takeaways:**

1. **Variables** make Terraform configurations reusable and flexible
2. **Types** ensure values are correct (string, number, bool, list, map, object, tuple)
3. **Precedence** determines which value is used (command-line > .tfvars > env vars > defaults)
4. **Validation** catches errors before resources are created
5. **Sensitive** variables hide values but don't encrypt them
6. **Defaults** provide fallback values
7. **Descriptions** document variable purpose
8. **Best practices** improve maintainability and security

**Next Steps:**
- Practice with different variable types
- Experiment with precedence order
- Add validation to your variables
- Learn about `for_each` with variables (see `for_each_and_variables_review.md`)

---

## Additional Resources

- [Terraform Variables Documentation](https://www.terraform.io/docs/language/values/variables.html)
- [Terraform Variable Types](https://www.terraform.io/docs/language/expressions/type-constraints.html)
- [Terraform Variable Validation](https://www.terraform.io/docs/language/values/variables.html#custom-validation-rules)
- [Terraform Variable Precedence](https://www.terraform.io/docs/cli/config/environment-variables.html#tf_var_name)

