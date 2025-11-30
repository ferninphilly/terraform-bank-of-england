# Exercise 6 Answer: Resource Group Level Policy Assignment

## Solution: Assign Policy to Resource Group Instead of Subscription

### Step 1: Create Test Resource Group

```hcl
resource "azurerm_resource_group" "test_policy_rg" {
  name     = "test-policy-rg"
  location = "eastus"
  
  tags = {
    department = "IT"
    project    = "PolicyTest"
  }
}
```

### Step 2: Create Resource Group Level Policy Assignment

```hcl
resource "azurerm_resource_group_policy_assignment" "location_rg" {
  name                 = "location-rg-assignment"
  resource_group_id    = azurerm_resource_group.test_policy_rg.id
  policy_definition_id = azurerm_policy_definition.location.id
}
```

**Key Difference:**
- Subscription assignment: `azurerm_subscription_policy_assignment`
- Resource group assignment: `azurerm_resource_group_policy_assignment`
- Uses `resource_group_id` instead of `subscription_id`

### Step 3: Test Policy Enforcement

#### Test 1: Resource in Assigned Resource Group

```hcl
resource "azurerm_storage_account" "test_in_rg" {
  name                     = "testinrg${random_id.suffix.hex}"
  resource_group_name      = azurerm_resource_group.test_policy_rg.name
  location                 = "japaneast"  # ❌ Non-compliant location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

**Expected:** Policy should block this (location not allowed)

#### Test 2: Resource in Different Resource Group

```hcl
resource "azurerm_resource_group" "other_rg" {
  name     = "other-rg"
  location = "eastus"
  
  tags = {
    department = "IT"
    project    = "Other"
  }
}

resource "azurerm_storage_account" "test_other_rg" {
  name                     = "testotherrg${random_id.suffix.hex}"
  resource_group_name      = azurerm_resource_group.other_rg.name
  location                 = "japaneast"  # ❌ Non-compliant, but policy not assigned here
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

**Expected:** This might succeed because policy is only assigned to `test_policy_rg`, not `other_rg`

**Note:** If there's also a subscription-level policy, it will still apply. Resource group policies are additive.

## Answers to Questions

### What's the difference between subscription and resource group assignments?

**Answer:**

| Aspect | Subscription Assignment | Resource Group Assignment |
|--------|------------------------|---------------------------|
| **Scope** | Entire subscription | Single resource group |
| **Resource Type** | `azurerm_subscription_policy_assignment` | `azurerm_resource_group_policy_assignment` |
| **ID Reference** | `subscription_id` | `resource_group_id` |
| **Impact** | All resources in subscription | Only resources in that resource group |
| **Use Case** | Organization-wide policies | Environment-specific policies |

**Key Point:** Policies are additive. A resource group policy adds to subscription policies, it doesn't replace them.

### When would you use resource group level policies?

**Answer:** Use resource group level policies when:

1. **Environment-Specific Rules:**
   - Production: Strict policies
   - Development: Relaxed policies
   - Different rules per environment

2. **Project-Specific Requirements:**
   - Special projects need exceptions
   - Different teams have different needs
   - Temporary policy overrides

3. **Gradual Rollout:**
   - Test policies on specific resource groups first
   - Roll out to more groups over time
   - Validate before subscription-wide deployment

4. **Cost Management:**
   - Different cost controls per project
   - Budget-specific restrictions

5. **Compliance:**
   - Specific compliance requirements for certain workloads
   - Regulatory requirements for specific data

### How do you scope policies to specific resources?

**Answer:** Azure Policy supports multiple scopes:

1. **Management Group:** Highest level, applies to multiple subscriptions
2. **Subscription:** Applies to entire subscription
3. **Resource Group:** Applies to single resource group
4. **Resource:** Can assign to individual resources (limited support)

**Terraform Resources:**
```hcl
# Management Group (if supported)
azurerm_management_group_policy_assignment

# Subscription
azurerm_subscription_policy_assignment

# Resource Group
azurerm_resource_group_policy_assignment

# Individual Resource (limited)
azurerm_resource_policy_assignment
```

**Scoping Hierarchy:**
```
Management Group
  └── Subscription
      └── Resource Group
          └── Resource
```

Policies inherit down the hierarchy and are additive.

## Complete Example

**main.tf:**
```hcl
# Resource Group for Policy Testing
resource "azurerm_resource_group" "test_policy_rg" {
  name     = "test-policy-rg"
  location = "eastus"
  
  tags = {
    department = "IT"
    project    = "PolicyTest"
  }
}

# Resource Group Level Policy Assignment
resource "azurerm_resource_group_policy_assignment" "location_rg" {
  name                 = "location-rg-assignment"
  resource_group_id    = azurerm_resource_group.test_policy_rg.id
  policy_definition_id = azurerm_policy_definition.location.id
  
  description = "Location policy for test resource group only"
}
```

## Testing Scenarios

### Scenario 1: Policy Only on Resource Group

```bash
# Apply resource group assignment only
terraform apply -target=azurerm_resource_group_policy_assignment.location_rg

# Try creating resource in assigned RG with bad location
terraform plan -target=azurerm_storage_account.test_in_rg
# Should fail - policy applies

# Try creating resource in other RG with bad location
terraform plan -target=azurerm_storage_account.test_other_rg
# Might succeed - policy doesn't apply to other RG
```

### Scenario 2: Both Subscription and Resource Group Policies

If you have both:
- Subscription policy: Allows eastus, westus
- Resource group policy: Allows only eastus

**Result:** Resource group policy is more restrictive, so only eastus is allowed in that RG.

## Best Practices

1. **Start Broad:** Begin with subscription-level policies
2. **Narrow Down:** Add resource group policies for exceptions
3. **Document Scope:** Clearly document why policies are scoped differently
4. **Test Thoroughly:** Verify policies work at intended scope
5. **Avoid Conflicts:** Ensure policies don't conflict unnecessarily

## Advanced: Multiple Resource Group Assignments

You can assign the same policy to multiple resource groups:

```hcl
locals {
  production_rgs = [
    azurerm_resource_group.prod_rg1.id,
    azurerm_resource_group.prod_rg2.id,
    azurerm_resource_group.prod_rg3.id
  ]
}

resource "azurerm_resource_group_policy_assignment" "location_prod" {
  for_each = {
    for idx, rg_id in local.production_rgs : idx => rg_id
  }
  
  name                 = "location-prod-${each.key}"
  resource_group_id    = each.value
  policy_definition_id = azurerm_policy_definition.location.id
}
```

## Summary

Resource group level assignments allow:
- Fine-grained policy control
- Environment-specific rules
- Gradual policy rollout
- Exception handling

Use them when you need policies that apply only to specific resource groups rather than the entire subscription.

