# Exercise 3 Answer: Multiple Locations Policy

## Solution: Enhanced Location Policy with Dynamic Locations

### Step 1: Update variables.tf

```hcl
variable "location" {
  type        = list(string)
  description = "List of allowed Azure regions"
  default     = [
    "eastus",
    "westus",
    "canadacentral",
    "westeurope",
    "uksouth"
  ]
}
```

### Step 2: Update Policy Definition in main.tf

The key is to use the entire list variable instead of indexing individual elements:

```hcl
resource "azurerm_policy_definition" "location" {
  name         = "location"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed location policy"
  description  = "Restricts resource creation to approved Azure regions"

  policy_rule = jsonencode({
    if = {
      field = "location",
      notIn = var.location  # Use entire list
    },
    then = {
      effect = "deny"
    }
  })
}
```

**Key Change:** Instead of:
```hcl
notIn = ["${var.location[0]}","${var.location[1]}"]  # ❌ Only first two
```

Use:
```hcl
notIn = var.location  # ✅ All locations in list
```

### Step 3: Test with Multiple Locations

Create test resources:

```hcl
# Compliant locations
resource "azurerm_resource_group" "test_eastus" {
  name     = "test-eastus-rg"
  location = "eastus"  # ✅ Compliant
  tags = {
    department = "IT"
    project    = "Test"
  }
}

resource "azurerm_resource_group" "test_canadacentral" {
  name     = "test-canada-rg"
  location = "canadacentral"  # ✅ Compliant (now allowed)
  tags = {
    department = "IT"
    project    = "Test"
  }
}

# Non-compliant location
resource "azurerm_resource_group" "test_japaneast" {
  name     = "test-japan-rg"
  location = "japaneast"  # ❌ Non-compliant - not in list
  tags = {
    department = "IT"
    project    = "Test"
  }
}
```

### Step 4: Update Existing Policy

If the policy already exists, you need to update it:

```bash
# Plan to see changes
terraform plan

# Apply updates
terraform apply
```

**Note:** Terraform will update the existing policy definition with new values.

## Answers to Questions

### How do you make a policy rule work with variable-length lists?
**Answer:** Use the list variable directly in the `notIn` operator:
```hcl
notIn = var.location
```
Terraform's JSON encoding handles the list automatically, so all values are included regardless of list length.

### What's the best way to maintain a list of allowed locations?
**Answer:** 
1. **Use variables:** Store in `variables.tf` for easy updates
2. **Use terraform.tfvars:** Override per environment
3. **Use locals:** If you need computed values
4. **Document:** Add descriptions explaining why locations are allowed

**Example with terraform.tfvars:**
```hcl
location = [
  "eastus",
  "westus",
  "canadacentral",
  "westeurope"
]
```

### How do you update an existing policy definition?
**Answer:** 
1. Modify the policy definition in Terraform code
2. Run `terraform plan` to see changes
3. Run `terraform apply` to update
4. Terraform will update the existing policy (same name = update, not create new)

**Important:** Policy updates can take a few minutes to propagate. Wait before testing.

## Advanced: Using Functions for Dynamic Lists

You can also use Terraform functions:

```hcl
locals {
  # Combine multiple lists
  all_allowed_locations = concat(
    var.primary_locations,
    var.secondary_locations
  )
  
  # Filter locations
  us_locations = [
    for loc in var.all_locations : loc
    if can(regex("us$", loc))
  ]
}

resource "azurerm_policy_definition" "location" {
  # ...
  policy_rule = jsonencode({
    if = {
      field = "location",
      notIn = local.all_allowed_locations
    },
    then = {
      effect = "deny"
    }
  })
}
```

## Testing

```bash
# Update variables
terraform plan
# Should show policy definition update

# Apply
terraform apply

# Test compliant locations
terraform apply -target=azurerm_resource_group.test_eastus
terraform apply -target=azurerm_resource_group.test_canadacentral

# Test non-compliant (should fail)
terraform plan -target=azurerm_resource_group.test_japaneast
# Error: Policy violation - location not allowed
```

## Complete Updated Configuration

**variables.tf:**
```hcl
variable "location" {
  type        = list(string)
  description = "List of allowed Azure regions for resource deployment"
  default     = [
    "eastus",
    "westus",
    "canadacentral",
    "westeurope",
    "uksouth"
  ]
}
```

**main.tf (updated policy):**
```hcl
resource "azurerm_policy_definition" "location" {
  name         = "location"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed location policy"

  policy_rule = jsonencode({
    if = {
      field = "location",
      notIn = var.location  # Dynamic list - all locations included
    },
    then = {
      effect = "deny"
    }
  })
}
```

## Best Practices

1. **Use descriptive variable names:** `allowed_locations` is clearer than `location`
2. **Add descriptions:** Document why locations are allowed
3. **Use defaults:** Provide sensible defaults
4. **Make it configurable:** Allow overrides via terraform.tfvars
5. **Document restrictions:** Explain business reasons for location limits

