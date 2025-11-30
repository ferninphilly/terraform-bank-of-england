# Exercise 5 Answer: Policy with Multiple Conditions (allOf)

## Solution: Policy Requiring All Tags

### Step 1: Update variables.tf

```hcl
variable "allowed_tags" {
  type        = list(string)
  description = "List of required tags that must be present on all resources"
  default     = ["department", "project", "costcenter"]
}
```

### Step 2: Create Policy with allOf Operator

```hcl
resource "azurerm_policy_definition" "required_tags_all" {
  name         = "required-tags-all"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "All Required Tags Policy"
  description  = "Requires all tags: department, project, and costcenter. All must be present."

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "tags[department]",
          exists = false
        },
        {
          field = "tags[project]",
          exists = false
        },
        {
          field = "tags[costcenter]",
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

**Wait!** The above logic is wrong. `allOf` with `exists = false` means "if ALL tags don't exist" - but we want "if ANY tag doesn't exist".

### Correct Solution: Use anyOf

```hcl
resource "azurerm_policy_definition" "required_tags_all" {
  name         = "required-tags-all"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "All Required Tags Policy"
  description  = "Requires all tags: department, project, and costcenter. All must be present."

  policy_rule = jsonencode({
    if = {
      anyOf = [  # If ANY tag is missing, deny
        {
          field = "tags[department]",
          exists = false
        },
        {
          field = "tags[project]",
          exists = false
        },
        {
          field = "tags[costcenter]",
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

**Logic:** If ANY tag doesn't exist, deny the resource. This ensures ALL tags must be present.

### Step 3: Create Policy Assignment

```hcl
resource "azurerm_subscription_policy_assignment" "required_tags_all" {
  name                 = "required-tags-all-assignment"
  policy_definition_id = azurerm_policy_definition.required_tags_all.id
  subscription_id      = data.azurerm_subscription.current.id
}
```

### Step 4: Test Various Tag Combinations

#### Test 1: All Tags Present (Compliant)

```hcl
resource "azurerm_resource_group" "test_all_tags" {
  name     = "test-all-tags-rg"
  location = "eastus"
  
  tags = {
    department  = "IT"        # ✅ Present
    project     = "Test"      # ✅ Present
    costcenter  = "CC001"     # ✅ Present
  }
}
```

**Expected:** Resource created successfully ✅

#### Test 2: Missing One Tag (Non-Compliant)

```hcl
resource "azurerm_resource_group" "test_missing_costcenter" {
  name     = "test-missing-cc-rg"
  location = "eastus"
  
  tags = {
    department = "IT"        # ✅ Present
    project    = "Test"     # ✅ Present
    # ❌ Missing costcenter tag
  }
}
```

**Expected:** Resource creation denied ❌

#### Test 3: Missing Multiple Tags (Non-Compliant)

```hcl
resource "azurerm_resource_group" "test_missing_multiple" {
  name     = "test-missing-multiple-rg"
  location = "eastus"
  
  tags = {
    department = "IT"  # ✅ Present
    # ❌ Missing project
    # ❌ Missing costcenter
  }
}
```

**Expected:** Resource creation denied ❌

#### Test 4: No Tags (Non-Compliant)

```hcl
resource "azurerm_resource_group" "test_no_tags" {
  name     = "test-no-tags-rg"
  location = "eastus"
  
  # ❌ No tags at all
}
```

**Expected:** Resource creation denied ❌

## Answers to Questions

### What's the difference between `anyOf` and `allOf`?

**Answer:**

| Operator | Logic | Meaning |
|---------|-------|---------|
| **anyOf** | OR | If ANY condition is true, the whole condition is true |
| **allOf** | AND | ALL conditions must be true for the whole condition to be true |

**Examples:**

**anyOf (OR logic):**
```hcl
anyOf = [
  { field = "tags[department]", exists = false },
  { field = "tags[project]", exists = false }
]
```
**Meaning:** If department tag is missing OR project tag is missing → deny

**allOf (AND logic):**
```hcl
allOf = [
  { field = "tags[department]", exists = false },
  { field = "tags[project]", exists = false }
]
```
**Meaning:** If department tag is missing AND project tag is missing → deny

**For requiring all tags, use anyOf:**
- If ANY tag is missing → deny
- This ensures ALL tags must be present

### How do you structure multiple conditions?

**Answer:** Use nested logical operators:

```hcl
policy_rule = jsonencode({
  if = {
    allOf = [  # All of these must be true
      {
        anyOf = [  # Any tag missing
          { field = "tags[department]", exists = false },
          { field = "tags[project]", exists = false }
        ]
      },
      {
        field = "location",
        notIn = ["eastus", "westus"]
      }
    ]
  },
  then = {
    effect = "deny"
  }
})
```

**Structure:**
- `allOf` / `anyOf` contain arrays of conditions
- Conditions can be nested
- Each condition is an object with `field` and operator

### What happens if one tag is missing?

**Answer:** With `anyOf` and `exists = false`:
- If ANY tag is missing → condition is true → effect (deny) is applied
- Resource creation is blocked
- Error message indicates which tag(s) are missing

## Alternative: Using allOf with Negation

You can also structure it differently:

```hcl
policy_rule = jsonencode({
  if = {
    allOf = [
      {
        field = "tags[department]",
        exists = true  # Must exist
      },
      {
        field = "tags[project]",
        exists = true  # Must exist
      },
      {
        field = "tags[costcenter]",
        exists = true  # Must exist
      }
    ],
    not = true  # Negate - deny if NOT all exist
  },
  then = {
    effect = "deny"
  }
})
```

**Note:** Check Azure Policy documentation for supported `not` syntax. The `anyOf` approach is more commonly used and reliable.

## Dynamic Tag List (Advanced)

For a dynamic number of tags:

```hcl
locals {
  required_tags = ["department", "project", "costcenter"]
  
  tag_conditions = [
    for tag in local.required_tags : {
      field = "tags[${tag}]",
      exists = false
    }
  ]
}

resource "azurerm_policy_definition" "required_tags_all" {
  # ...
  policy_rule = jsonencode({
    if = {
      anyOf = local.tag_conditions
    },
    then = {
      effect = "deny"
    }
  })
}
```

## Complete Example

**variables.tf:**
```hcl
variable "allowed_tags" {
  type        = list(string)
  description = "List of required tags"
  default     = ["department", "project", "costcenter"]
}
```

**main.tf:**
```hcl
resource "azurerm_policy_definition" "required_tags_all" {
  name         = "required-tags-all"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "All Required Tags Policy"

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
        },
        {
          field = "tags[${var.allowed_tags[2]}]",
          exists = false
        }
      ]
    },
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "required_tags_all" {
  name                 = "required-tags-all-assignment"
  policy_definition_id = azurerm_policy_definition.required_tags_all.id
  subscription_id      = data.azurerm_subscription.current.id
}
```

## Testing

```bash
# Apply policy
terraform apply

# Test compliant resource
terraform apply -target=azurerm_resource_group.test_all_tags
# ✅ Should succeed

# Test non-compliant (missing tag)
terraform plan -target=azurerm_resource_group.test_missing_costcenter
# ❌ Should fail with policy violation
```

## Key Takeaways

1. **Use `anyOf` with `exists = false`** to require all tags
2. **Logic:** If ANY tag is missing → deny (ensures ALL must be present)
3. **Test thoroughly** with different tag combinations
4. **Document** which tags are required and why

