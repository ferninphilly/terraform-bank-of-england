# Exercise 10 Answer: Troubleshooting Module Issues

## Scenario Solutions

### Scenario 1: Module Not Found

**Error:**
```
Error: Module not found

  on main.tf line 6:
   6: module "ServicePrincipal" {

The module source "./modules/ServicePrincipal" could not be found.
```

**Root Cause:**
- Module directory doesn't exist
- Incorrect path in `source` attribute
- Module not initialized

**Solution:**
```bash
# Check if module directory exists
ls -la modules/ServicePrincipal/

# Verify source path is correct
# In main.tf, ensure:
module "ServicePrincipal" {
  source = "./modules/ServicePrincipal"  # Correct path
  # NOT: source = "./modules/serviceprincipal" (case-sensitive on Linux)
}

# Initialize Terraform
terraform init
```

**Prevention:**
- Use consistent naming (case-sensitive)
- Verify paths before committing
- Run `terraform init` after adding modules

---

### Scenario 2: Variable Not Set

**Error:**
```
Error: Missing required variable "location"

  on main.tf line 15:
  15: module "keyvault" {
  
The root module input variable "location" is not set, and has no default value.
```

**Root Cause:**
- Required variable not provided in `terraform.tfvars`
- Variable not set via command line or environment variable
- Variable name mismatch

**Solution:**
```bash
# Option 1: Add to terraform.tfvars
echo 'location = "canadacentral"' >> terraform.tfvars

# Option 2: Set via command line
terraform apply -var="location=canadacentral"

# Option 3: Set via environment variable
export TF_VAR_location="canadacentral"
terraform apply

# Option 4: Add default to variables.tf
variable "location" {
  type    = string
  default = "canadacentral"  # Add default
}
```

**Prevention:**
- Provide defaults for commonly used variables
- Document required variables
- Use `terraform validate` to catch early

---

### Scenario 3: Output Not Available

**Error:**
```
Error: Reference to undeclared output value

  on main.tf line 20:
  20:   principal_id = module.ServicePrincipal.service_principal_object_id
  
An output value with the name "service_principal_object_id" has not been declared
in module "ServicePrincipal".
```

**Root Cause:**
- Output doesn't exist in module's `output.tf`
- Output name typo
- Module not applied yet (outputs created after apply)

**Solution:**
```bash
# Check module outputs
cat modules/ServicePrincipal/output.tf

# Verify output name matches exactly (case-sensitive)
# Correct: service_principal_object_id
# Wrong:   service_principal_Object_ID

# Apply module first to create outputs
terraform apply -target=module.ServicePrincipal

# Then use the output
terraform apply
```

**Prevention:**
- Use consistent naming conventions
- Document all outputs
- Test module outputs independently

---

### Scenario 4: Circular Dependency

**Error:**
```
Error: Cycle detected

  module.ServicePrincipal
  module.keyvault
  module.ServicePrincipal
```

**Root Cause:**
- Module A depends on Module B
- Module B depends on Module A
- Circular reference chain

**Example of Circular Dependency:**
```hcl
# Module A uses Module B's output
module "module_a" {
  source = "./modules/a"
  value_from_b = module.module_b.output_value
}

# Module B uses Module A's output (CIRCULAR!)
module "module_b" {
  source = "./modules/b"
  value_from_a = module.module_a.output_value
}
```

**Solution:**
```hcl
# Break the cycle by:
# 1. Remove unnecessary dependency
# 2. Use a shared resource instead
# 3. Restructure to eliminate circular reference

# Example: Use resource group directly instead of through module
module "module_a" {
  source = "./modules/a"
  resource_group_name = azurerm_resource_group.rg.name  # Direct reference
}

module "module_b" {
  source = "./modules/b"
  resource_group_name = azurerm_resource_group.rg.name  # Direct reference
}
```

**Prevention:**
- Design modules with clear dependency hierarchy
- Avoid bidirectional dependencies
- Use shared resources for common dependencies

---

### Scenario 5: Module Version Mismatch

**Error:**
```
Error: Unsupported argument

  on main.tf line 10:
  10:   new_variable = "value"
  
An argument named "new_variable" is not expected here.
```

**Root Cause:**
- Module updated but root module not refreshed
- Module structure changed
- Using wrong module version

**Solution:**
```bash
# Option 1: Refresh modules
terraform init -upgrade

# Option 2: Check module version (if using Git)
# Update source to correct version
module "example" {
  source = "git::https://github.com/org/repo.git//modules/example?ref=v1.2.0"
}

# Option 3: Update root module to match new structure
# Remove old variables, add new ones
```

**Prevention:**
- Pin module versions in production
- Document module version requirements
- Test module updates in dev first

---

## Common Module Troubleshooting Commands

### Check Module Status
```bash
# List all modules
terraform get

# Show module tree
terraform providers

# Validate configuration
terraform validate
```

### Debug Module Issues
```bash
# Show detailed plan
terraform plan -detailed-exitcode

# Show module structure
terraform show

# Check module source
terraform init -upgrade -verbose
```

### Fix Common Issues
```bash
# Clean and reinitialize
rm -rf .terraform
terraform init

# Format code
terraform fmt -recursive

# Validate syntax
terraform validate
```

---

## Diagnostic Checklist

When troubleshooting module issues, check:

- [ ] **Module exists:** `ls modules/module-name/`
- [ ] **Source path correct:** Check `source` attribute matches directory
- [ ] **Variables defined:** Check module's `variables.tf`
- [ ] **Outputs defined:** Check module's `output.tf`
- [ ] **Terraform initialized:** Run `terraform init`
- [ ] **Syntax valid:** Run `terraform validate`
- [ ] **Dependencies correct:** Check `depends_on` and variable references
- [ ] **No circular dependencies:** Trace dependency chain
- [ ] **Module applied:** Outputs only exist after apply
- [ ] **Case sensitivity:** Module names match exactly (Linux/Mac)

---

## Error Message Patterns

### Pattern 1: Path Issues
```
Error: Failed to load module
```
**Check:** Source path, directory existence, permissions

### Pattern 2: Variable Issues
```
Error: Missing required variable
Error: Unsupported argument
```
**Check:** Variable names, types, defaults, terraform.tfvars

### Pattern 3: Output Issues
```
Error: Reference to undeclared output
```
**Check:** Output names, module applied, output.tf file

### Pattern 4: Dependency Issues
```
Error: Cycle detected
Error: Resource not found
```
**Check:** Dependency order, depends_on, variable references

---

## Prevention Strategies

1. **Use terraform validate:** Catch errors early
2. **Run terraform plan:** See what will happen before apply
3. **Version control:** Track module changes
4. **Documentation:** Document module interfaces
5. **Testing:** Test modules independently
6. **Code review:** Review module changes carefully
7. **CI/CD:** Automate validation and testing

---

## Getting Help

### Useful Commands
```bash
# Get help for specific command
terraform <command> -help

# Show version
terraform version

# Show providers
terraform providers

# Show state
terraform state list
terraform state show <resource>
```

### Debugging Tips
1. **Enable verbose logging:**
   ```bash
   export TF_LOG=DEBUG
   terraform plan
   ```

2. **Check Terraform state:**
   ```bash
   terraform state list
   terraform state show module.ServicePrincipal
   ```

3. **Validate specific module:**
   ```bash
   cd modules/keyvault
   terraform init
   terraform validate
   ```

4. **Test module in isolation:**
   ```bash
   # Create test directory
   mkdir test-module
   cd test-module
   
   # Create test main.tf
   cat > main.tf <<EOF
   module "test" {
     source = "../modules/keyvault"
     # ... variables
   }
   EOF
   
   # Test
   terraform init
   terraform plan
   ```

