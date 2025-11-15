# 📋 Task: Understanding Terraform Variable Precedence

This task will guide you through testing and verifying Terraform's variable precedence hierarchy. You'll learn how Terraform resolves variables when multiple sources provide values.

## 🎯 Learning Objectives

By the end of this task, you will:
- Understand Terraform's variable precedence order
- Know how to pass variables using different methods
- Be able to verify which variable value takes precedence
- Understand when to use each method

---

## 📚 Variable Precedence Hierarchy (Highest to Lowest)

Terraform resolves variables in this order (highest precedence first):

1. **Command-line flags** (`-var` or `-var-file`)
2. **Environment variables** (`TF_VAR_<variable_name>`)
3. **`terraform.tfvars` file** (in the current directory)
4. **`terraform.tfvars.json` file** (in the current directory)
5. **`*.auto.tfvars` files** (in alphabetical order)
6. **Default values** (defined in `variables.tf`)

---

## ✅ Prerequisites

Before starting, ensure you have:
- Completed the previous task (Step 2)
- Your `main.tf` file with the `environment` variable defined
- Terraform initialized (`terraform init`)

---

## 📝 Step-by-Step Instructions

### Step 1: Review Current Configuration

1. **Check your `main.tf` file** - Verify you have:
   ```terraform
   variable "environment" {
     type        = string
     description = "the env type"
     default     = "staging"
   }
   ```

2. **Verify the variable is used** - Check that `var.environment` is referenced somewhere in your resources (e.g., in tags or resource names)

### Step 2: Create a Test Output

Add this output to your `main.tf` to help verify variable values:

```terraform
output "environment_value" {
  value       = var.environment
  description = "Shows the resolved value of the environment variable"
}
```

### Step 3: Test 1 - Default Value (Lowest Precedence)

**Objective:** Verify that the default value is used when no other source provides a value.

1. **Ensure no other variable sources exist:**
   ```bash
   # Remove terraform.tfvars if it exists
   rm -f terraform.tfvars terraform.tfvars.json *.auto.tfvars
   
   # Unset any environment variables
   unset TF_VAR_environment
   ```

2. **Run Terraform plan:**
   ```bash
   terraform plan
   ```

3. **Verify the output:**
   - Check the `environment_value` output
   - **Expected value:** `staging` (the default)
   - **Record your result:** ________________

4. **What this proves:** Default values are used when no other source provides a value.

---

### Step 4: Test 2 - terraform.tfvars File

**Objective:** Verify that `terraform.tfvars` overrides default values.

1. **Create `terraform.tfvars` file:**
   ```bash
   cat > terraform.tfvars << EOF
   environment = "demo"
   EOF
   ```

2. **Run Terraform plan:**
   ```bash
   terraform plan
   ```

3. **Verify the output:**
   - Check the `environment_value` output
   - **Expected value:** `demo` (from terraform.tfvars)
   - **Record your result:** ________________

4. **What this proves:** `terraform.tfvars` overrides default values.

---

### Step 5: Test 3 - Environment Variable

**Objective:** Verify that environment variables override `terraform.tfvars`.

1. **Keep `terraform.tfvars` with `environment = "demo"`**

2. **Set an environment variable:**
   ```bash
   export TF_VAR_environment="production"
   ```

3. **Run Terraform plan:**
   ```bash
   terraform plan
   ```

4. **Verify the output:**
   - Check the `environment_value` output
   - **Expected value:** `production` (from environment variable)
   - **Record your result:** ________________

5. **What this proves:** Environment variables override `terraform.tfvars`.

6. **Clean up:**
   ```bash
   unset TF_VAR_environment
   ```

---

### Step 6: Test 4 - Command-Line Flag (Highest Precedence)

**Objective:** Verify that command-line flags override everything else.

1. **Keep `terraform.tfvars` with `environment = "demo"`**

2. **Set an environment variable:**
   ```bash
   export TF_VAR_environment="production"
   ```

3. **Run Terraform plan with command-line flag:**
   ```bash
   terraform plan -var="environment=development"
   ```

4. **Verify the output:**
   - Check the `environment_value` output
   - **Expected value:** `development` (from command-line flag)
   - **Record your result:** ________________

5. **What this proves:** Command-line flags have the highest precedence.

6. **Clean up:**
   ```bash
   unset TF_VAR_environment
   ```

---

### Step 7: Test 5 - Multiple .auto.tfvars Files

**Objective:** Understand how multiple `.auto.tfvars` files work.

1. **Create multiple `.auto.tfvars` files:**
   ```bash
   # Create first file (alphabetically first)
   cat > a.auto.tfvars << EOF
   environment = "alpha-env"
   EOF
   
   # Create second file (alphabetically second)
   cat > z.auto.tfvars << EOF
   environment = "zeta-env"
   EOF
   ```

2. **Remove terraform.tfvars:**
   ```bash
   rm -f terraform.tfvars
   ```

3. **Run Terraform plan:**
   ```bash
   terraform plan
   ```

4. **Verify the output:**
   - Check the `environment_value` output
   - **Expected value:** `zeta-env` (from z.auto.tfvars - loaded last alphabetically)
   - **Record your result:** ________________

5. **What this proves:** `.auto.tfvars` files are loaded in alphabetical order, with later files overriding earlier ones.

6. **Clean up:**
   ```bash
   rm -f *.auto.tfvars
   ```

---

### Step 8: Complete Variable Precedence Test

**Objective:** Test all precedence levels together to see the complete hierarchy.

1. **Set up all variable sources:**
   ```bash
   # Default value: "staging" (already in variables.tf)
   
   # terraform.tfvars
   cat > terraform.tfvars << EOF
   environment = "demo"
   EOF
   
   # Environment variable
   export TF_VAR_environment="production"
   ```

2. **Run Terraform plan WITHOUT command-line flag:**
   ```bash
   terraform plan
   ```
   - **Expected value:** `production` (environment variable wins)
   - **Record your result:** ________________

3. **Run Terraform plan WITH command-line flag:**
   ```bash
   terraform plan -var="environment=development"
   ```
   - **Expected value:** `development` (command-line flag wins)
   - **Record your result:** ________________

4. **Clean up:**
   ```bash
   unset TF_VAR_environment
   rm -f terraform.tfvars
   ```

---

## 📊 Summary Table

Fill out this table as you complete each test:

| Test | Variable Source | Expected Value | Actual Value | Precedence Level |
|------|----------------|----------------|--------------|-----------------|
| 1 | Default only | staging | _____ | 6 (Lowest) |
| 2 | terraform.tfvars | demo | _____ | 3 |
| 3 | Environment variable | production | _____ | 2 |
| 4 | Command-line flag | development | _____ | 1 (Highest) |
| 5 | Multiple .auto.tfvars | zeta-env | _____ | 4-5 |

---

## 🎓 Key Takeaways

1. **Command-line flags** (`-var`) have the **highest precedence**
2. **Environment variables** (`TF_VAR_*`) override files but not command-line
3. **terraform.tfvars** overrides defaults but not environment variables
4. **Default values** are used only when no other source provides a value
5. **Multiple `.auto.tfvars` files** are processed alphabetically

---

## 🔍 Verification Checklist

Before completing this task, verify:

- [ ] You've tested all 5 scenarios
- [ ] You understand which method has highest precedence
- [ ] You've recorded your results in the summary table
- [ ] You can explain why each test produced its result
- [ ] You've cleaned up test files and environment variables

---

## 💡 Bonus Challenge

Create a scenario where:
1. Default value = "staging"
2. terraform.tfvars = "demo"
3. Environment variable = "production"
4. Command-line flag = "development"

**Question:** What will be the final value? Why?

**Answer:** `development` - because command-line flags have the highest precedence.

---

## 🚨 Common Mistakes to Avoid

1. **Forgetting to unset environment variables** between tests
2. **Not removing terraform.tfvars** when testing defaults
3. **Confusing variable names** (must match exactly, case-sensitive)
4. **Not checking the output** to verify the actual value used

---

## 📚 Additional Resources

- [Terraform Variable Precedence Documentation](https://developer.hashicorp.com/terraform/language/values/variables#variable-definition-precedence)
- [Terraform Input Variables](https://developer.hashicorp.com/terraform/language/values/variables)

---

## ✅ Completion

Once you've completed all tests and filled out the summary table, you've successfully verified Terraform's variable precedence hierarchy!

