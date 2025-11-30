# Task: Creating and Using a Simple Module

This task focuses on the fundamentals of Terraform modules - creating a reusable module in a separate directory and using it with variables.

## Learning Objectives

By the end of this task, you will:
- Understand what a Terraform module is
- Know how to create a module in a separate directory
- Learn how to pass variables to a module
- Understand how to use module outputs
- Practice module best practices

## What is a Module?

A **module** is a container for multiple resources that are used together. Think of it as a reusable "function" that creates a set of related resources.

**Benefits:**
- ✅ **Reusability**: Write once, use many times
- ✅ **Organization**: Group related resources together
- ✅ **Abstraction**: Hide complexity behind a simple interface
- ✅ **Maintainability**: Update module, all uses benefit

## Task Overview

Create a simple **Resource Group module** that can be reused across different environments and projects.

### Module Structure

```
modules/
└── resource-group/
    ├── main.tf      # Resource group resource
    ├── variables.tf # Module input variables
    └── outputs.tf   # Module outputs
```

### Root Module Structure

```
.
├── main.tf           # Uses the module
├── variables.tf      # Root module variables
├── outputs.tf        # Root module outputs
├── provider.tf       # Provider configuration
├── backend.tf        # Backend configuration
└── modules/
    └── resource-group/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Step-by-Step Instructions

### Step 1: Create Module Directory Structure

1. Create the module directory:
   ```bash
   mkdir -p modules/resource-group
   ```

2. Create module files:
   ```bash
   touch modules/resource-group/main.tf
   touch modules/resource-group/variables.tf
   touch modules/resource-group/outputs.tf
   ```

### Step 2: Create Module Variables

**File: `modules/resource-group/variables.tf`**

Define what inputs the module accepts:

```hcl
variable "name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the resource group"
  type        = string
  
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2",
      "westeurope", "northeurope"
    ], var.location)
    error_message = "Location must be in allowed regions."
  }
}

variable "tags" {
  description = "Tags to apply to the resource group"
  type        = map(string)
  default     = {}
}
```

**Key Points:**
- Module variables define the module's "interface"
- No defaults required (can be provided by root module)
- Validation ensures correct values

### Step 3: Create Module Resource

**File: `modules/resource-group/main.tf`**

Create the actual resource using module variables:

```hcl
resource "azurerm_resource_group" "main" {
  name     = var.name
  location = var.location
  tags     = var.tags
}
```

**Key Points:**
- Uses `var.name`, `var.location`, `var.tags` from module variables
- This is the same resource you'd create in root module
- Module encapsulates this resource

### Step 4: Create Module Outputs

**File: `modules/resource-group/outputs.tf`**

Expose information from the module:

```hcl
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}
```

**Key Points:**
- Outputs expose module information to root module
- Access via `module.resource_group.output_name`
- Useful for passing to other resources/modules

### Step 5: Use Module in Root Module

**File: `main.tf`**

Call the module and pass variables:

```hcl
module "resource_group" {
  source = "./modules/resource-group"
  
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
```

**Key Points:**
- `source` points to module directory
- Pass root module variables to module variables
- Module name (`resource_group`) is how you reference it

### Step 6: Create Root Module Variables

**File: `variables.tf`**

Define variables for the root module:

```hcl
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "myproject-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
  
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2",
      "westeurope", "northeurope"
    ], var.location)
    error_message = "Location must be in allowed regions."
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "MyProject"
    ManagedBy   = "Terraform"
  }
}
```

### Step 7: Create Root Module Outputs

**File: `outputs.tf`**

Expose module outputs:

```hcl
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "ID of the created resource group"
  value       = module.resource_group.resource_group_id
}

output "resource_group_location" {
  description = "Location of the created resource group"
  value       = module.resource_group.resource_group_location
}
```

**Key Points:**
- Access module outputs: `module.module_name.output_name`
- Can pass to other resources or expose to users

### Step 8: Initialize and Use

1. **Initialize Terraform** (downloads modules):
   ```bash
   terraform init
   ```

2. **Plan** to see what will be created:
   ```bash
   terraform plan
   ```

3. **Apply** to create resources:
   ```bash
   terraform apply
   ```

## Understanding Module Variable Flow

```
Root Module Variables (variables.tf)
         ↓
    main.tf (module block)
         ↓
Module Variables (modules/resource-group/variables.tf)
         ↓
Module Resources (modules/resource-group/main.tf)
         ↓
Module Outputs (modules/resource-group/outputs.tf)
         ↓
Root Module Outputs (outputs.tf)
```

## Key Concepts

### 1. Module Source

```hcl
module "resource_group" {
  source = "./modules/resource-group"  # Local path
  # OR
  source = "git::https://github.com/..."  # Git repository
  # OR
  source = "registry.terraform.io/..."  # Terraform Registry
}
```

### 2. Passing Variables

```hcl
module "resource_group" {
  source = "./modules/resource-group"
  
  # Direct assignment
  name     = var.resource_group_name
  
  # Direct value
  location = "eastus"
  
  # Computed value
  tags = merge(var.common_tags, { Environment = var.environment })
}
```

### 3. Accessing Module Outputs

```hcl
# In outputs.tf
output "rg_name" {
  value = module.resource_group.resource_group_name
}

# In other resources
resource "azurerm_storage_account" "main" {
  resource_group_name = module.resource_group.resource_group_name
  # ...
}
```

## Common Patterns

### Pattern 1: Multiple Module Instances

```hcl
module "rg_dev" {
  source = "./modules/resource-group"
  
  name     = "myproject-dev-rg"
  location = "eastus"
  tags = {
    Environment = "dev"
  }
}

module "rg_prod" {
  source = "./modules/resource-group"
  
  name     = "myproject-prod-rg"
  location = "westus2"
  tags = {
    Environment = "prod"
  }
}
```

### Pattern 2: Using Module Outputs

```hcl
module "resource_group" {
  source = "./modules/resource-group"
  # ...
}

resource "azurerm_storage_account" "main" {
  name                = "mystorage"
  resource_group_name = module.resource_group.resource_group_name  # Use module output
  location            = module.resource_group.resource_group_location
  # ...
}
```

### Pattern 3: Conditional Module Usage

```hcl
variable "create_resource_group" {
  type    = bool
  default = true
}

module "resource_group" {
  source = "./modules/resource-group"
  count  = var.create_resource_group ? 1 : 0
  
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
```

## Best Practices

1. ✅ **One module per directory**: Keep modules separate
2. ✅ **Clear variable names**: Use descriptive names
3. ✅ **Document variables**: Always include descriptions
4. ✅ **Validate inputs**: Use validation rules
5. ✅ **Expose outputs**: Make module information available
6. ✅ **Use defaults wisely**: Provide sensible defaults
7. ✅ **Keep modules focused**: One module, one purpose

## Troubleshooting

### Error: "Module not found"

**Problem:** Module source path is incorrect.

**Solution:**
- Check `source` path is correct
- Use relative paths: `./modules/resource-group`
- Run `terraform init` to download modules

### Error: "Required variable not set"

**Problem:** Module variable has no default and wasn't provided.

**Solution:**
- Provide variable in module block
- Or add default to module variable

### Error: "Invalid value for variable"

**Problem:** Value doesn't match module variable type/validation.

**Solution:**
- Check module variable type
- Verify value matches expected format
- Check validation rules

## Next Steps

After completing this task:
- Create more complex modules (VNet, Storage Account, VM)
- Use modules with for_each
- Create module dependencies
- Learn about module versioning

## Deliverables

- ✅ Complete module structure (`modules/resource-group/`)
- ✅ Root module using the module (`main.tf`)
- ✅ Variables for both root and module
- ✅ Outputs for both root and module
- ✅ Working Terraform configuration

