# Exercise 4 Answer: Audit-Only Policy

## Solution: Create Audit Policy for Environment Tag

### Step 1: Create Policy Definition with Audit Effect

```hcl
resource "azurerm_policy_definition" "audit_environment_tag" {
  name         = "audit-environment-tag"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Audit Environment Tag Policy"
  description  = "Audits resources that do not have an environment tag. Does not block creation."

  policy_rule = jsonencode({
    if = {
      field = "tags[environment]",
      exists = false
    },
    then = {
      effect = "audit"  # Audit instead of deny
    }
  })
}
```

### Step 2: Create Policy Assignment

```hcl
resource "azurerm_subscription_policy_assignment" "audit_environment" {
  name                 = "audit-environment-assignment"
  policy_definition_id = azurerm_policy_definition.audit_environment_tag.id
  subscription_id      = data.azurerm_subscription.current.id
}
```

### Step 3: Test with Resource Without Tag

Create a test resource:

```hcl
resource "azurerm_resource_group" "test_no_environment_tag" {
  name     = "test-no-env-tag-rg"
  location = "eastus"
  
  # ❌ Missing environment tag
  tags = {
    department = "IT"
    project    = "Test"
  }
}
```

**Expected Result:**
- Resource WILL be created (not blocked)
- Resource will be marked as non-compliant
- Compliance status can be viewed in Azure Portal

### Step 4: Check Compliance Status

**In Azure Portal:**
1. Go to Policy → Compliance
2. Find "Audit Environment Tag Policy"
3. View compliance status
4. See which resources are non-compliant

**Using Terraform (if data source available):**
```hcl
# Note: Compliance data sources may have limited availability
# Check Azure Portal for compliance status
```

## Answers to Questions

### What's the difference between `deny` and `audit`?
**Answer:**

| Effect | Behavior | Use Case |
|--------|----------|----------|
| **deny** | Blocks resource creation/update | Enforce strict compliance, prevent violations |
| **audit** | Allows creation but logs violation | Monitor compliance without blocking, gradual enforcement |

**Key Differences:**
- `deny`: Stops non-compliant resources from being created
- `audit`: Allows creation but marks as non-compliant for reporting

### When would you use `audit` instead of `deny`?
**Answer:** Use `audit` when:
1. **Gradual Enforcement:** You want to see impact before blocking
2. **Monitoring:** You need compliance visibility without disruption
3. **Existing Resources:** You have existing non-compliant resources
4. **Testing:** You're testing policy impact
5. **Flexibility:** You want to allow exceptions temporarily

**Migration Path:**
1. Start with `audit` to understand impact
2. Fix existing non-compliant resources
3. Switch to `deny` for strict enforcement

### How do you view audit results?
**Answer:**

**Method 1: Azure Portal**
1. Navigate to Policy → Compliance
2. Select your subscription
3. View policy compliance status
4. Click on policy to see non-compliant resources

**Method 2: Azure CLI**
```bash
# List policy compliance states
az policy state list --policy-assignment "audit-environment-assignment"

# Get compliance summary
az policy state summarize --policy-assignment "audit-environment-assignment"
```

**Method 3: PowerShell**
```powershell
# Get compliance states
Get-AzPolicyState -PolicyAssignmentName "audit-environment-assignment"
```

## Testing Steps

### Test 1: Create Resource Without Tag

```bash
# Apply resource without environment tag
terraform apply -target=azurerm_resource_group.test_no_environment_tag

# Expected: Resource created successfully
# Check Azure Portal for compliance status
```

### Test 2: Create Resource With Tag

```hcl
resource "azurerm_resource_group" "test_with_environment_tag" {
  name     = "test-with-env-tag-rg"
  location = "eastus"
  
  # ✅ Has environment tag
  tags = {
    department = "IT"
    project    = "Test"
    environment = "dev"  # Compliant
  }
}
```

```bash
terraform apply -target=azurerm_resource_group.test_with_environment_tag

# Expected: Resource created and marked as compliant
```

### Test 3: Switch to Deny

To test the difference, temporarily change effect to `deny`:

```hcl
then = {
  effect = "deny"  # Changed from audit
}
```

```bash
terraform apply
# Now try to create resource without tag - should be blocked
```

## Complete Example

**main.tf addition:**
```hcl
# Audit Policy for Environment Tag
resource "azurerm_policy_definition" "audit_environment_tag" {
  name         = "audit-environment-tag"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Audit Environment Tag Policy"
  description  = "Audits resources missing environment tag"

  policy_rule = jsonencode({
    if = {
      field = "tags[environment]",
      exists = false
    },
    then = {
      effect = "audit"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "audit_environment" {
  name                 = "audit-environment-assignment"
  policy_definition_id = azurerm_policy_definition.audit_environment_tag.id
  subscription_id      = data.azurerm_subscription.current.id
}
```

## Best Practices

1. **Start with Audit:** Use audit to understand impact before denying
2. **Monitor Compliance:** Regularly check compliance status
3. **Fix Non-Compliance:** Address non-compliant resources
4. **Gradual Enforcement:** Move from audit to deny over time
5. **Document Rationale:** Explain why audit vs deny was chosen

## Comparison: Audit vs Deny

### Audit Policy Flow
```
Resource Creation Request
    ↓
Policy Evaluation
    ↓
Missing Tag? → Yes → Allow Creation + Mark Non-Compliant
    ↓
No → Allow Creation + Mark Compliant
```

### Deny Policy Flow
```
Resource Creation Request
    ↓
Policy Evaluation
    ↓
Missing Tag? → Yes → Block Creation + Return Error
    ↓
No → Allow Creation
```

## Advanced: Conditional Effects

You can also use conditional logic:

```hcl
policy_rule = jsonencode({
  if = {
    allOf = [
      {
        field = "tags[environment]",
        exists = false
      },
      {
        field = "type",
        equals = "Microsoft.Resources/resourceGroups"
      }
    ]
  },
  then = {
    effect = "audit"  # Audit for resource groups
  },
  else = {
    effect = "deny"   # Deny for other resources
  }
})
```

**Note:** Not all policy rule structures support `else`. Check Azure Policy documentation for supported syntax.

