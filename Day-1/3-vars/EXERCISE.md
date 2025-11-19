# Exercise: Understanding Terraform Variables

This exercise will help you understand the basics of Terraform variables, locals, and outputs.

## 🎯 What You'll Learn

- How to define and use variables
- Different ways to set variable values
- How to use local values
- How to create outputs

---

## Part 1: Understanding Variables

### What are Variables?

Variables in Terraform are like placeholders that allow you to customize your configuration without hardcoding values. Think of them as inputs to your Terraform code.

### Step 1: Define a Variable

Look at your `main.tf` file. You should see a variable definition like this:

```hcl
variable "environment" {
  type        = string
  description = "the env type"
  default     = "staging"
}
```

**Breaking it down:**
- `variable "environment"` - This is the variable name
- `type = string` - The variable must be a text value
- `description` - Explains what the variable is for
- `default = "staging"` - If no value is provided, use "staging"

### Step 2: Use the Variable

In your `main.tf`, find where `var.environment` is used. It should look like:

```hcl
tags = merge(local.common_tags, {
  environment = var.environment
})
```

**Key Point:** Use `var.variable_name` to reference a variable in your code.

---

## Part 2: Setting Variable Values

There are several ways to set variable values. Let's try them!

### Method 1: Default Value (Easiest)

**What happens:** Terraform uses the default value you defined.

1. Make sure you don't have a `terraform.tfvars` file:
   ```bash
   rm -f terraform.tfvars
   ```

2. Run Terraform plan:
   ```bash
   terraform plan
   ```

3. Check the output - you should see `environment_value = "staging"`

**Why?** Because no other value was provided, Terraform used the default.

### Method 2: Using terraform.tfvars File

**What happens:** Create a file that Terraform automatically reads.

1. Create a file named `terraform.tfvars`:
   ```bash
   cat > terraform.tfvars << EOF
   environment = "demo"
   EOF
   ```

2. Run Terraform plan:
   ```bash
   terraform plan
   ```

3. Check the output - you should see `environment_value = "demo"`

**Why?** The `terraform.tfvars` file overrides the default value.

**💡 Tip:** This is great for different environments (dev, staging, prod) - just use different `.tfvars` files!

### Method 3: Using Command Line

**What happens:** Pass the value directly when running Terraform.

1. Keep your `terraform.tfvars` file with `environment = "demo"`

2. Run Terraform plan with a command-line flag:
   ```bash
   terraform plan -var="environment=production"
   ```

3. Check the output - you should see `environment_value = "production"`

**Why?** Command-line values override file values.

**💡 Tip:** Useful for one-time changes without editing files.

### Method 4: Using Environment Variables

**What happens:** Set a system environment variable.

1. Set an environment variable:
   ```bash
   export TF_VAR_environment="development"
   ```

2. Run Terraform plan:
   ```bash
   terraform plan
   ```

3. Check the output - you should see `environment_value = "development"`

4. Clean up:
   ```bash
   unset TF_VAR_environment
   ```

**Why?** Environment variables are useful for CI/CD pipelines or when you don't want to store values in files.

**💡 Tip:** The format is always `TF_VAR_` followed by the variable name.

---

## Part 3: Understanding Variable Precedence

When multiple sources provide values, Terraform uses this order (highest to lowest):

1. **Command-line flags** (`-var`) - Highest priority
2. **Environment variables** (`TF_VAR_*`)
3. **terraform.tfvars file**
4. **Default values** - Lowest priority

### Quick Test

Try this to see precedence in action:

```bash
# Set default to "staging" (already in your code)
# Create terraform.tfvars with "demo"
echo 'environment = "demo"' > terraform.tfvars

# Set environment variable to "production"
export TF_VAR_environment="production"

# Run with command-line flag
terraform plan -var="environment=development"
```

**Question:** What value will be used?

**Answer:** `development` - because command-line flags have the highest precedence!

---

## Part 4: Understanding Locals

### What are Locals?

Locals are like variables, but they're calculated values used only within your configuration. They're great for values you compute once and reuse multiple times.

### Look at Your Locals

In your `main.tf`, you should see:

```hcl
locals {
  common_tags = {
    environment = "dev"
    lob         = "banking"
    stage       = "alpha"
  }
}
```

**Key Points:**
- `locals` block defines local values
- Use `local.common_tags` to reference them (not `var.`)
- Great for values that don't need to be changed by users

### Using Locals

In your storage account, you can see locals being used:

```hcl
tags = merge(local.common_tags, {
  environment = var.environment
})
```

**What's happening:**
- `merge()` combines two maps (objects)
- `local.common_tags` provides base tags
- `var.environment` overrides the environment tag

**💡 Tip:** Locals are perfect for computed values, repeated strings, or default configurations.

---

## Part 5: Understanding Outputs

### What are Outputs?

Outputs are values that Terraform displays after running. They're like return values from your configuration.

### Look at Your Outputs

In your `main.tf`, you should see:

```hcl
output "storage_account_name" {
  value       = azurerm_storage_account.example.name
  description = "The name of the storage account"
}

output "environment_value" {
  value       = var.environment
  description = "Shows the resolved value of the environment variable"
}
```

**Key Points:**
- `output "name"` defines an output
- `value` is what gets displayed
- `description` explains what the output shows

### Viewing Outputs

After running `terraform apply`, you'll see outputs automatically. You can also view them anytime:

```bash
terraform output
```

Or get a specific output:

```bash
terraform output storage_account_name
```

**💡 Tip:** Outputs are great for getting resource IDs, names, or other important values after deployment.

---

## 🎯 Practice Exercises

### Exercise 1: Add a New Variable

1. Add a variable for `location` with default value `"West Europe"`
2. Use it in your resource group instead of hardcoding
3. Test it by creating a `terraform.tfvars` file with `location = "East US"`

### Exercise 2: Create a Local Value

1. Create a local value called `resource_prefix` with value `"boe"`
2. Use it to prefix your resource names (e.g., `"${local.resource_prefix}-storage"`)

### Exercise 3: Add an Output

1. Add an output for the resource group location
2. Run `terraform apply` and verify you can see the output

### Exercise 4: Test Precedence

1. Set a default value for a variable
2. Create a `terraform.tfvars` file with a different value
3. Set an environment variable with yet another value
4. Run `terraform plan` and see which value wins
5. Override it with a command-line flag

---

## 📝 Quick Reference

| Concept | Syntax | Example |
|---------|--------|---------|
| **Define Variable** | `variable "name" { ... }` | `variable "environment" { default = "staging" }` |
| **Use Variable** | `var.name` | `var.environment` |
| **Define Local** | `locals { name = value }` | `locals { prefix = "boe" }` |
| **Use Local** | `local.name` | `local.prefix` |
| **Define Output** | `output "name" { value = ... }` | `output "rg_name" { value = azurerm_resource_group.example.name }` |
| **Set via tfvars** | Create `terraform.tfvars` | `environment = "demo"` |
| **Set via CLI** | `-var="name=value"` | `terraform plan -var="environment=prod"` |
| **Set via Env Var** | `export TF_VAR_name=value` | `export TF_VAR_environment=prod` |

---

## ✅ Checklist

Before moving on, make sure you can:

- [ ] Define a variable with a default value
- [ ] Use a variable in your resources
- [ ] Set a variable using `terraform.tfvars`
- [ ] Set a variable using command-line flags
- [ ] Set a variable using environment variables
- [ ] Explain which method has highest precedence
- [ ] Create and use a local value
- [ ] Create an output and view it

---

## 🎓 Key Takeaways

1. **Variables** = Inputs that users can customize
2. **Locals** = Internal values computed within your config
3. **Outputs** = Values displayed after Terraform runs
4. **Precedence** = Command-line > Environment > tfvars > Default
5. **Best Practice** = Use defaults for sensible defaults, tfvars for different environments

---

## 🚀 Next Steps

Once you're comfortable with these concepts:
- Try the detailed `TASK.md` for advanced precedence testing
- Experiment with different variable types (list, map, object)
- Learn about variable validation rules

Happy Terraforming! 🎉

