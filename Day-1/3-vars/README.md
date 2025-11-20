## Task for Step 03

This module focuses on understanding Terraform variables and their precedence hierarchy.

### Quick Overview

- Using the files created in the previous task (step 2), update them to use variables below
- Add an input variable named "environment" and set the default value to "staging"
- Create the terraform.tfvars file and set the environment value to demo
- Test the variable precedence by passing the variables in different ways: tfvars file, environment variables, default, etc.
- Create a local variable with a tag called common_tags with values as env=dev, lob=banking, stage=alpha, and use the local variable in the tags section of main.tf
- Create an output variable to print the storage account name

### 📋 Detailed Instructions

**👉 See [TASK.md](./TASK.md) for step-by-step instructions on testing variable precedence hierarchy.**

The TASK.md file contains:
- Complete variable precedence hierarchy explanation
- 8 detailed test scenarios to verify precedence
- Step-by-step instructions with expected results
- Summary table to track your progress
- Common mistakes to avoid

### 🔀 Ternary Operators

Terraform supports conditional expressions using ternary operators. This allows you to set values based on conditions.

**Syntax:**
```hcl
condition ? true_value : false_value
```

**Example:**
```hcl
subscription_id = var.subscription_id != "" ? var.subscription_id : null
```

This means:
- **If** `var.subscription_id` is not empty (`!= ""`), **then** use `var.subscription_id`
- **Otherwise**, use `null`

**Common Use Cases:**
- Providing default values when a variable is empty
- Conditional resource creation
- Environment-specific configurations

**See the answer key for a practical example of ternary operators in use.**

### Files in this directory:

- `main.tf` - Main Terraform configuration with variables, locals, and resources
- `terraform.tfvars.example` - Example tfvars file (copy to terraform.tfvars)
- `TASK.md` - Detailed task instructions for variable precedence testing
- `README.md` - This file
