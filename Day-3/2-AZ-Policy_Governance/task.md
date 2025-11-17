# Task: Azure Policy and Governance with Terraform

This module demonstrates how to create and manage Azure Policies using Terraform to enforce governance and compliance across your Azure subscription.

## Learning Objectives

By completing this task, you will learn:
- How to create Azure Policy definitions using Terraform
- How to assign policies to subscriptions
- How to use data sources to fetch subscription information
- How to enforce governance rules (location, VM sizes, tags)
- How to test policy enforcement
- How to create compliant and non-compliant resources

## Assignment Requirements

1. **Create three Azure Policy definitions:**
   - Location restriction (limit to specific regions like eastus, westus)
   - VM size control (restrict to cost-effective sizes: Standard_B2s, Standard_B2ms)
   - Mandatory tagging (enforce department and project tags)

2. **Assign policies to subscription:**
   - Use data source to fetch subscription details
   - Assign all three policies to the subscription

3. **Test policy enforcement:**
   - Verify policies are working
   - Create compliant resources
   - Attempt to create non-compliant resources and observe failures

---

## Prerequisites

Before starting, ensure you have:
- Azure subscription with appropriate permissions
- Terraform installed (version >= 1.9.0)
- Azure CLI installed and configured
- Permissions to create and assign policies (typically requires Policy Contributor or Owner role)
- Access to the subscription you'll be working with

**Required Azure Permissions:**
- `Microsoft.Authorization/policyDefinitions/write` - Create policy definitions
- `Microsoft.Authorization/policyAssignments/write` - Assign policies
- `Microsoft.Authorization/policySetDefinitions/write` - Create policy sets (if needed)

---

## Step-by-Step Instructions

### Step 1: Review Current Configuration

1. **Examine the existing files:**
   - `main.tf` - Contains policy definitions and assignments
   - `variables.tf` - Contains policy configuration variables
   - `rg.tf` - Contains test resource groups
   - `provider.tf` - Provider configuration
   - `backend.tf` - Backend configuration

2. **Understand the structure:**
   - Policy definitions define the rules
   - Policy assignments apply policies to scopes (subscription, resource group, etc.)
   - Data sources fetch current subscription information

### Step 2: Understand Azure Policy Structure

Azure Policies have three main components:

1. **Policy Definition** - The rule itself (what to check)
2. **Policy Assignment** - Where to apply the rule (subscription, resource group, etc.)
3. **Policy Effect** - What happens when non-compliant (deny, audit, etc.)

### Step 3: Create Location Restriction Policy

**Objective:** Restrict resource creation to specific Azure regions.

1. **Review the location policy in `main.tf`:**

```hcl
resource "azurerm_policy_definition" "location" {
  name         = "location"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed location policy"

  policy_rule = jsonencode({
    if = {
      field = "location",
      notIn = ["${var.location[0]}","${var.location[1]}"]
    },
    then = {
      effect = "deny"
    }
  })
}
```

**Understanding the Policy Rule:**
- `if.field = "location"` - Check the location field
- `notIn` - If location is NOT in the allowed list
- `then.effect = "deny"` - Deny the resource creation

2. **Check variables in `variables.tf`:**
```hcl
variable "location" {
  type = list(string)
  default = [ "eastus", "westus" ]
}
```

3. **Create the policy assignment:**
```hcl
resource "azurerm_subscription_policy_assignment" "example2" {
  name                 = "location-assignment"
  policy_definition_id = azurerm_policy_definition.location.id
  subscription_id      = data.azurerm_subscription.current.id
}
```

### Step 4: Create VM Size Control Policy

**Objective:** Restrict VM sizes to cost-effective options.

1. **Review the VM size policy:**

```hcl
resource "azurerm_policy_definition" "vm_size" {
  name         = "vm-size"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed vm policy"

  policy_rule = jsonencode({
    if = {
      field = "Microsoft.Compute/virtualMachines/sku.name",
      notIn = ["${var.vm_sizes[0]}","${var.vm_sizes[1]}"]
    },
    then = {
      effect = "deny"
    }
  })
}
```

**Understanding the Policy Rule:**
- `field = "Microsoft.Compute/virtualMachines/sku.name"` - Check VM SKU name
- `notIn` - If VM size is NOT in allowed list
- `then.effect = "deny"` - Deny VM creation

2. **Check allowed VM sizes:**
```hcl
variable "vm_sizes" {
  type = list(string)
  default = [ "Standard_B2s","Standard_B2ms" ]
}
```

3. **Create the assignment:**
```hcl
resource "azurerm_subscription_policy_assignment" "example1" {
  name                 = "size-assignment"
  policy_definition_id = azurerm_policy_definition.vm_size.id
  subscription_id      = data.azurerm_subscription.current.id
}
```

### Step 5: Create Mandatory Tagging Policy

**Objective:** Enforce required tags on all resources.

1. **Review the tagging policy:**

```hcl
resource "azurerm_policy_definition" "tag" {
  name         = "allowed-tag"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed tags policy"

  policy_rule = jsonencode({
    if = {
      anyOf = [
        {
          field = "tags[${var.allowed_tags[0]}]",
          exists = false
        },
        {
          field = "tags[${var.allowed_tags[1]}]",
          exists = false
        }
      ]
    },
    then = {
      effect = "deny"
    }
  })
}
```

**Understanding the Policy Rule:**
- `anyOf` - If ANY of these conditions are true
- `tags[department]` - Check if department tag exists
- `tags[project]` - Check if project tag exists
- `exists = false` - Tag doesn't exist
- `then.effect = "deny"` - Deny if tags are missing

2. **Check required tags:**
```hcl
variable "allowed_tags" {
  type = list(string)
  default = ["department","project"]
}
```

3. **Create the assignment:**
```hcl
resource "azurerm_subscription_policy_assignment" "example" {
  name                 = "tag-assignment"
  policy_definition_id = azurerm_policy_definition.tag.id
  subscription_id      = data.azurerm_subscription.current.id
}
```

### Step 6: Use Data Source for Subscription

**Objective:** Dynamically fetch subscription information.

1. **Review the data source:**

```hcl
data "azurerm_subscription" "current" {}
```

2. **This data source provides:**
   - `id` - Subscription ID
   - `display_name` - Subscription display name
   - `tenant_id` - Tenant ID
   - `subscription_id` - Subscription ID (same as id)

3. **Use in policy assignments:**
```hcl
subscription_id = data.azurerm_subscription.current.id
```

### Step 7: Initialize and Plan

1. **Initialize Terraform:**
```bash
terraform init
```

2. **Review the plan:**
```bash
terraform plan
```

**Expected Output:**
- 3 policy definitions will be created
- 3 policy assignments will be created
- Data source will fetch subscription information

3. **Verify the plan shows:**
```
+ azurerm_policy_definition.location
+ azurerm_policy_definition.tag
+ azurerm_policy_definition.vm_size
+ azurerm_subscription_policy_assignment.example
+ azurerm_subscription_policy_assignment.example1
+ azurerm_subscription_policy_assignment.example2
```

### Step 8: Apply the Configuration

1. **Apply the policies:**
```bash
terraform apply
```

Type `yes` when prompted, or use:
```bash
terraform apply -auto-approve
```

2. **Wait for completion:**
   - Policy definitions are created first
   - Then policy assignments are created
   - This usually takes 1-2 minutes

3. **Verify in Azure Portal:**
   - Go to Azure Portal → Policy → Definitions
   - You should see your three custom policies:
     - "Allowed location policy"
     - "Allowed vm policy"
     - "Allowed tags policy"
   
   - Go to Azure Portal → Policy → Assignments
   - You should see three assignments at the subscription level

### Step 9: Test Policy Enforcement - Compliant Resources

**Objective:** Verify that compliant resources can be created.

1. **Test compliant resource group:**

The existing `rg.tf` has compliant resource groups:
```hcl
resource "azurerm_resource_group" "rg" {
  name     = "test-rg"
  location = "eastus"  # ✅ Compliant - in allowed list
  
  tags = {
    department = "IT"      # ✅ Compliant - required tag
    project    = "Accelerator"  # ✅ Compliant - required tag
  }
}
```

2. **Apply the resource group:**
```bash
terraform apply
```

3. **Expected Result:**
   - Resource group should be created successfully
   - No policy violations

### Step 10: Test Policy Enforcement - Non-Compliant Resources

**Objective:** Verify that non-compliant resources are blocked.

#### Test 1: Non-Compliant Location

1. **Create a test file `test-noncompliant.tf`:**

```hcl
resource "azurerm_resource_group" "test_bad_location" {
  name     = "test-bad-location-rg"
  location = "canadacentral"  # ❌ Non-compliant - not in allowed list
  
  tags = {
    department = "IT"
    project    = "Test"
  }
}
```

2. **Try to apply:**
```bash
terraform plan
```

3. **Expected Result:**
   - Plan should fail with policy violation error
   - Error message should indicate location restriction

#### Test 2: Missing Tags

1. **Create another test:**

```hcl
resource "azurerm_resource_group" "test_missing_tags" {
  name     = "test-missing-tags-rg"
  location = "eastus"  # ✅ Compliant location
  
  # ❌ Missing required tags
  tags = {
    environment = "dev"  # Has tags, but missing department and project
  }
}
```

2. **Try to apply:**
```bash
terraform plan
```

3. **Expected Result:**
   - Plan should fail
   - Error should indicate missing required tags

#### Test 3: Non-Compliant VM Size

1. **Create a test VM:**

```hcl
resource "azurerm_virtual_machine" "test_bad_size" {
  name                  = "test-vm"
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.rg.name
  vm_size               = "Standard_D2s_v3"  # ❌ Non-compliant - not in allowed list
  
  # ... other VM configuration
}
```

2. **Try to apply:**
```bash
terraform plan
```

3. **Expected Result:**
   - Plan should fail
   - Error should indicate VM size restriction

### Step 11: Verify Policies in Azure Portal

1. **Check Policy Compliance:**
   - Go to Azure Portal → Policy → Compliance
   - You should see compliance status for your subscription
   - Resources should show as compliant or non-compliant

2. **View Policy Effects:**
   - Go to Azure Portal → Policy → Assignments
   - Click on each assignment
   - Review the policy definition and scope

3. **Test Manual Resource Creation:**
   - Try creating a resource group in Azure Portal
   - Use a non-compliant location (e.g., canadacentral)
   - Portal should show policy violation

### Step 12: Clean Up Test Resources

1. **Remove test files:**
```bash
# If you created test-noncompliant.tf, remove it
rm test-noncompliant.tf
```

2. **Destroy test resources:**
```bash
terraform destroy -target=azurerm_resource_group.rg
terraform destroy -target=azurerm_resource_group.rg1
```

3. **Keep policies (optional):**
   - Policies remain active unless explicitly destroyed
   - To remove policies:
     ```bash
     terraform destroy
     ```

---

## Understanding Policy Effects

Azure Policies support different effects:

| Effect | Description | Use Case |
|--------|-------------|----------|
| **deny** | Blocks resource creation/update | Enforce strict compliance |
| **audit** | Allows but logs non-compliance | Monitor without blocking |
| **modify** | Automatically adds missing properties | Auto-remediation |
| **append** | Adds properties to resources | Add tags automatically |
| **disabled** | Policy is not enforced | Temporarily disable |

**Current Configuration:** All policies use `deny` effect for strict enforcement.

---

## Policy Rule Syntax

### Common Policy Fields

- `location` - Resource location
- `tags[tagName]` - Specific tag
- `type` - Resource type
- `name` - Resource name
- `Microsoft.Compute/virtualMachines/sku.name` - VM SKU

### Common Operators

- `equals` - Exact match
- `notEquals` - Not equal
- `in` - Value in list
- `notIn` - Value not in list
- `exists` - Field exists
- `contains` - String contains
- `like` - Pattern match

### Logical Operators

- `allOf` - All conditions must be true (AND)
- `anyOf` - Any condition must be true (OR)
- `not` - Negate condition

---

## Troubleshooting

### Issue: Policy Not Enforcing

**Symptoms:** Non-compliant resources are created successfully

**Solutions:**
1. **Check policy assignment scope:**
   ```bash
   terraform state show azurerm_subscription_policy_assignment.example
   ```

2. **Verify policy is assigned:**
   - Check Azure Portal → Policy → Assignments
   - Ensure assignment exists and is enabled

3. **Check policy effect:**
   - Verify effect is "deny" not "audit"
   - Audit allows creation but logs violations

4. **Wait for propagation:**
   - Policies can take 5-15 minutes to propagate
   - Wait and try again

### Issue: Policy Blocks Compliant Resources

**Symptoms:** Compliant resources are blocked

**Solutions:**
1. **Verify variable values:**
   ```bash
   terraform console
   > var.location
   > var.vm_sizes
   > var.allowed_tags
   ```

2. **Check policy rule logic:**
   - Review JSON policy rule
   - Verify conditions are correct

3. **Test with terraform plan:**
   - Use `terraform plan` to see policy errors
   - Review error messages carefully

### Issue: Permission Denied

**Error:** `Authorization failed`

**Solutions:**
1. **Check Azure permissions:**
   ```bash
   az role assignment list --assignee $(az account show --query user.name -o tsv)
   ```

2. **Required roles:**
   - Policy Contributor (minimum)
   - Owner (full access)

3. **Request permissions from subscription administrator**

### Issue: Policy Definition Already Exists

**Error:** `Policy definition already exists`

**Solutions:**
1. **Use different name:**
   ```hcl
   name = "location-policy-${random_id.suffix.hex}"
   ```

2. **Import existing policy:**
   ```bash
   terraform import azurerm_policy_definition.location /subscriptions/.../...
   ```

3. **Delete existing policy first** (if safe to do so)

---

## Best Practices

1. **Use Descriptive Names:**
   - Policy names should clearly indicate purpose
   - Use consistent naming conventions

2. **Organize with Policy Sets:**
   - Group related policies together
   - Use policy initiatives (policy sets)

3. **Start with Audit:**
   - Begin with "audit" effect to understand impact
   - Switch to "deny" after validation

4. **Test Thoroughly:**
   - Test both compliant and non-compliant scenarios
   - Verify policies work as expected

5. **Document Policies:**
   - Add descriptions to policy definitions
   - Document business justification

6. **Use Variables:**
   - Make policies configurable
   - Easy to update without changing code

7. **Version Control:**
   - Store policy definitions in Git
   - Track changes over time

---

## Verification Checklist

- [ ] All three policy definitions created
- [ ] All three policy assignments created
- [ ] Data source fetches subscription correctly
- [ ] Compliant resource group created successfully
- [ ] Non-compliant location blocked
- [ ] Missing tags blocked
- [ ] Non-compliant VM size blocked (if tested)
- [ ] Policies visible in Azure Portal
- [ ] Compliance status shows correctly

---

## Key Concepts Learned

- **Policy Definitions:** Rules that define what to check
- **Policy Assignments:** Application of policies to scopes
- **Policy Effects:** What happens when non-compliant (deny, audit, etc.)
- **Data Sources:** Fetching current Azure information
- **JSON Policy Rules:** Structure of policy logic
- **Governance:** Enforcing organizational standards

---

## Next Steps

After completing this task, consider:
- Creating policy sets (initiatives) to group policies
- Using policy effects like "modify" for auto-remediation
- Creating policies at resource group level
- Implementing policy exemptions for special cases
- Setting up policy compliance monitoring

---

## Files in this directory:

- `main.tf` - Policy definitions and assignments
- `variables.tf` - Policy configuration variables
- `rg.tf` - Test resource groups
- `provider.tf` - Provider configuration
- `backend.tf` - Backend configuration
- `task.md` - This file

---

## Quick Reference

**Initialize:**
```bash
terraform init
```

**Plan:**
```bash
terraform plan
```

**Apply:**
```bash
terraform apply
```

**View State:**
```bash
terraform state list
terraform state show azurerm_policy_definition.location
```

**Destroy:**
```bash
terraform destroy
```

