## Task for step-5 - Type Constraints

This module focuses on understanding and using Terraform variable type constraints.

### Learning Objectives

Using the files from previous task (step 05), understand the use of the below type constraints:

- **Name:** `environment`, **type:** `string`
- **Name:** `storage-disk`, **type:** `number`
- **Name:** `is_delete`, **type:** `boolean`
- **Name:** `allowed_locations`, **type:** `list(string)`
- **Name:** `resource_tags`, **type:** `map(string)`
- **Name:** `network_config`, **type:** `tuple([string, string, number])`
- **Name:** `allowed_vm_sizes`, **type:** `list(string)`
- **Name:** `vm_config`, **type:** `object({...})`
  ```terraform
  type = object({
    size         = string
    publisher    = string
    offer        = string
    sku          = string
    version      = string
  })
  ```

### 📋 Detailed Exercises

**👉 See [EXERCISES.md](./EXERCISES.md) for comprehensive hands-on exercises on type constraints.**

The EXERCISES.md file contains:
- Detailed explanation of all 7 type constraints
- 10 hands-on exercises with step-by-step instructions
- Practice tasks for each type (string, number, bool, list, map, tuple, object)
- Common error scenarios and how to fix them
- Type validation challenges
- Bonus challenges for advanced practice

### Files in this directory:

- `variables.tf` - Contains examples of all type constraints
- `main.tf` - Shows how to use variables with different types
- `EXERCISES.md` - Detailed exercise guide (start here!)
- `README.md` - This file
- `backend.tf` - Backend configuration
- `provider.tf` - Provider configuration
- `local.tf` - Local values
- `output.tf` - Output definitions

### Quick Start

1. Review the type constraints in `variables.tf`
2. See how they're used in `main.tf`
3. Follow the exercises in `EXERCISES.md` to practice
4. Test your understanding with the validation challenges
