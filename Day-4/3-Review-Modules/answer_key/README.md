# Answer Key: Simple Resource Group Module

This directory contains a complete working example of creating and using a Terraform module.

## Overview

This example demonstrates:
- ✅ Creating a module in a separate directory
- ✅ Defining module variables
- ✅ Using module variables in module resources
- ✅ Creating module outputs
- ✅ Calling a module from root module
- ✅ Passing variables to a module
- ✅ Using module outputs

## Directory Structure

```
answer_key/
├── backend.tf                    # Backend configuration
├── provider.tf                   # Provider configuration
├── variables.tf                  # Root module variables
├── main.tf                       # Root module (calls the module)
├── output.tf                     # Root module outputs
├── terraform.tfvars.example      # Example variable values
└── modules/
    └── resource-group/
        ├── variables.tf          # Module input variables
        ├── main.tf               # Module resource
        └── outputs.tf            # Module outputs
```

## How It Works

### 1. Module Definition

**`modules/resource-group/variables.tf`**
- Defines what inputs the module accepts
- `name`: Resource group name (required)
- `location`: Azure region (required, with validation)
- `tags`: Tags map (optional, defaults to empty)

**`modules/resource-group/main.tf`**
- Creates the actual resource group resource
- Uses module variables: `var.name`, `var.location`, `var.tags`

**`modules/resource-group/outputs.tf`**
- Exposes resource group information
- Can be accessed via `module.resource_group.output_name`

### 2. Root Module Usage

**`main.tf`**
- Calls the module using `module` block
- `source` points to module directory: `./modules/resource-group`
- Passes root module variables to module variables

**`variables.tf`**
- Defines variables for root module
- These are passed to the module

**`output.tf`**
- Exposes module outputs
- Accesses via `module.resource_group.output_name`

## Variable Flow

```
Root Module Variables (variables.tf)
         ↓
    main.tf (module block passes variables)
         ↓
Module Variables (modules/resource-group/variables.tf)
         ↓
Module Resource (modules/resource-group/main.tf)
         ↓
Module Outputs (modules/resource-group/outputs.tf)
         ↓
Root Module Outputs (output.tf)
```

## Usage

### 1. Copy Example Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit Variables (Optional)

Edit `terraform.tfvars` with your values:
```hcl
resource_group_name = "my-custom-rg"
location           = "westus2"

tags = {
  Environment = "prod"
  Project     = "MyProject"
}
```

### 3. Initialize Terraform

```bash
terraform init
```

This will:
- Download the Azure provider
- Initialize the module (creates `.terraform/modules/`)

### 4. Review Plan

```bash
terraform plan
```

**Expected Output:**
```
Terraform will perform the following actions:

  # module.resource_group.azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "myproject-rg"
      + tags     = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Project"     = "MyProject"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

### 5. Apply Configuration

```bash
terraform apply
```

### 6. View Outputs

```bash
terraform output
```

**Expected Output:**
```
resource_group_id       = "/subscriptions/.../resourceGroups/myproject-rg"
resource_group_location = "eastus"
resource_group_name     = "myproject-rg"
```

## Key Concepts Demonstrated

### Module Source

```hcl
module "resource_group" {
  source = "./modules/resource-group"  # Local path to module
  # ...
}
```

**Source Types:**
- **Local**: `./modules/resource-group`
- **Git**: `git::https://github.com/...`
- **Registry**: `registry.terraform.io/...`

### Passing Variables to Module

```hcl
module "resource_group" {
  source = "./modules/resource-group"
  
  # Pass root module variable
  name     = var.resource_group_name
  
  # Pass root module variable
  location = var.location
  
  # Pass root module variable
  tags     = var.tags
}
```

**Key Points:**
- Module variables are assigned in the module block
- Can pass variables, literals, or computed values
- Variable names must match module variable names

### Accessing Module Outputs

```hcl
# In outputs.tf
output "resource_group_name" {
  value = module.resource_group.resource_group_name
}

# In other resources
resource "azurerm_storage_account" "main" {
  resource_group_name = module.resource_group.resource_group_name
  # ...
}
```

**Syntax:** `module.module_name.output_name`

## Advanced Patterns

### Pattern 1: Multiple Module Instances

Create multiple resource groups:

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

### Pattern 2: Using Module Outputs in Other Resources

```hcl
module "resource_group" {
  source = "./modules/resource-group"
  # ...
}

resource "azurerm_storage_account" "main" {
  name                = "mystorageaccount"
  resource_group_name = module.resource_group.resource_group_name
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

# Access with index when using count
output "rg_name" {
  value = var.create_resource_group ? module.resource_group[0].resource_group_name : null
}
```

## Module Best Practices

1. ✅ **One module per directory**: Keep modules separate and focused
2. ✅ **Clear variable names**: Use descriptive, consistent names
3. ✅ **Document everything**: Add descriptions to all variables and outputs
4. ✅ **Validate inputs**: Use validation rules to catch errors early
5. ✅ **Expose outputs**: Make module information available to root module
6. ✅ **Use defaults wisely**: Provide sensible defaults for optional values
7. ✅ **Keep modules focused**: One module should do one thing well
8. ✅ **Version modules**: Use version constraints when using remote modules

## Troubleshooting

### Error: "Module not found"

**Problem:** Module source path is incorrect.

**Solution:**
- Verify `source` path: `./modules/resource-group`
- Check directory exists
- Run `terraform init` to initialize modules

### Error: "Required variable not set"

**Problem:** Module variable has no default and wasn't provided.

**Solution:**
- Provide variable in module block in `main.tf`
- Or add default value to module variable

### Error: "Invalid value for variable"

**Problem:** Value doesn't match module variable type or validation.

**Solution:**
- Check module variable type in `modules/resource-group/variables.tf`
- Verify value matches expected format
- Check validation rules

### Module Not Initialized

**Problem:** Module directory exists but Terraform doesn't see it.

**Solution:**
```bash
terraform init
# Or force reinitialization
terraform init -upgrade
```

## Understanding Module References

### In Root Module

```hcl
# Call module
module "resource_group" {
  source = "./modules/resource-group"
  # ...
}

# Use module output
output "rg_name" {
  value = module.resource_group.resource_group_name
}

# Use module output in resource
resource "azurerm_storage_account" "main" {
  resource_group_name = module.resource_group.resource_group_name
}
```

### Module Internal

```hcl
# Use module variable
resource "azurerm_resource_group" "main" {
  name     = var.name      # Module variable
  location = var.location  # Module variable
}

# Create module output
output "resource_group_name" {
  value = azurerm_resource_group.main.name
}
```

## Next Steps

After understanding this basic module:
- Create more complex modules (VNet, Storage Account, VM)
- Use modules with for_each
- Create module dependencies (one module uses another)
- Learn about module versioning
- Explore remote modules (Git, Terraform Registry)

## Summary

**Key Takeaways:**

1. **Modules** are reusable containers for related resources
2. **Module variables** define the module's interface
3. **Module outputs** expose module information
4. **Call modules** using `module` blocks in root module
5. **Pass variables** from root to module in module block
6. **Access outputs** via `module.module_name.output_name`
7. **Initialize** modules with `terraform init`

**This pattern** is the foundation for all Terraform modules, from simple to complex!

