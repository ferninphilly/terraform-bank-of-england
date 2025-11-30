# Exercise 11 Answer: Resource Naming Convention Policy

## Solution: Enforce Naming Conventions with Pattern Matching

### Step 1: Create Policy with Pattern Matching

```hcl
resource "azurerm_policy_definition" "resource_naming_convention" {
  name         = "resource-naming-convention"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Resource Naming Convention Policy"
  description  = "Enforces naming convention: environment-resourcetype-uniqueid"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type",
          equals = "Microsoft.Resources/resourceGroups"
        },
        {
          field = "name",
          notLike = "*-*-rg"  # Pattern: env-type-rg
        }
      ]
    },
    then = {
      effect = "deny"
    }
  })
}
```

**Note:** The `like` operator uses wildcard patterns:
- `*` matches any characters
- `?` matches single character (if supported)

### Step 2: More Specific Pattern Matching

For resource groups with specific environment prefixes:

```hcl
resource "azurerm_policy_definition" "resource_naming_convention" {
  name         = "resource-naming-convention"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Resource Naming Convention Policy"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type",
          equals = "Microsoft.Resources/resourceGroups"
        },
        {
          anyOf = [
            {
              field = "name",
              like = "dev-*-rg"
            },
            {
              field = "name",
              like = "staging-*-rg"
            },
            {
              field = "name",
              like = "prod-*-rg"
            }
          ],
          not = true  # Deny if NOT matching any pattern
        }
      ]
    },
    then = {
      effect = "deny"
    }
  })
}
```

**Simpler Approach - Use notLike:**

```hcl
resource "azurerm_policy_definition" "resource_naming_convention" {
  name         = "resource-naming-convention"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Resource Naming Convention Policy"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type",
          equals = "Microsoft.Resources/resourceGroups"
        },
        {
          field = "name",
          notLike = "dev-*-rg"
        },
        {
          field = "name",
          notLike = "staging-*-rg"
        },
        {
          field = "name",
          notLike = "prod-*-rg"
        }
      ]
    },
    then = {
      effect = "deny"
    }
  })
}
```

**Better Approach - Use regex (if supported) or multiple conditions:**

```hcl
resource "azurerm_policy_definition" "resource_naming_convention" {
  name         = "resource-naming-convention"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Resource Naming Convention Policy"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type",
          equals = "Microsoft.Resources/resourceGroups"
        },
        {
          anyOf = [
            {
              field = "name",
              like = "dev-*-rg"
            },
            {
              field = "name",
              like = "staging-*-rg"
            },
            {
              field = "name",
              like = "prod-*-rg"
            }
          ],
          not = true  # Deny if name does NOT match any pattern
        }
      ]
    },
    then = {
      effect = "deny"
    }
  })
}
```

### Step 3: Create Policy Assignment

```hcl
resource "azurerm_subscription_policy_assignment" "naming_convention" {
  name                 = "naming-convention-assignment"
  policy_definition_id = azurerm_policy_definition.resource_naming_convention.id
  subscription_id      = data.azurerm_subscription.current.id
}
```

### Step 4: Test Naming Patterns

#### Test 1: Compliant Names

```hcl
# ✅ Compliant - matches dev-*-rg pattern
resource "azurerm_resource_group" "test_compliant_dev" {
  name     = "dev-app-rg"
  location = "eastus"
}

# ✅ Compliant - matches prod-*-rg pattern
resource "azurerm_resource_group" "test_compliant_prod" {
  name     = "prod-database-rg"
  location = "eastus"
}

# ✅ Compliant - matches staging-*-rg pattern
resource "azurerm_resource_group" "test_compliant_staging" {
  name     = "staging-web-rg"
  location = "eastus"
}
```

**Expected:** All should be created successfully ✅

#### Test 2: Non-Compliant Names

```hcl
# ❌ Non-compliant - doesn't match any pattern
resource "azurerm_resource_group" "test_noncompliant_1" {
  name     = "test-rg"  # Missing environment prefix
  location = "eastus"
}

# ❌ Non-compliant - wrong format
resource "azurerm_resource_group" "test_noncompliant_2" {
  name     = "myresourcegroup"  # No dashes, no pattern
  location = "eastus"
}

# ❌ Non-compliant - wrong suffix
resource "azurerm_resource_group" "test_noncompliant_3" {
  name     = "dev-app-group"  # Ends with "group" not "rg"
  location = "eastus"
}
```

**Expected:** All should be blocked ❌

## Answers to Questions

### How does the `like` operator work?

**Answer:** The `like` operator performs pattern matching with wildcards:

- `*` - Matches zero or more characters
- `?` - Matches exactly one character (if supported)

**Examples:**
- `like = "dev-*-rg"` matches: `dev-app-rg`, `dev-web-rg`, `dev-123-rg`
- `like = "prod-*-rg"` matches: `prod-db-rg`, `prod-api-rg`
- `notLike` - Negates the pattern match

**Limitations:**
- Case-sensitive matching
- Limited regex support (use `match` for regex if available)
- Wildcard patterns only

### What pattern syntax is used?

**Answer:** Azure Policy uses simple wildcard patterns:

**Supported Patterns:**
- `*` - Zero or more characters
- `?` - Single character (check documentation for support)

**Not Supported:**
- Full regex (use `match` operator if available)
- Character classes `[a-z]`
- Quantifiers `{n,m}`

**Alternative - Use `match` for regex:**
```hcl
{
  field = "name",
  match = "^dev-[a-z0-9]+-rg$"  # Regex pattern
}
```

**Check Azure Policy documentation** for current support of `match` operator.

### How do you handle multiple naming patterns?

**Answer:** Use `anyOf` to allow multiple patterns:

```hcl
anyOf = [
  { field = "name", like = "dev-*-rg" },
  { field = "name", like = "staging-*-rg" },
  { field = "name", like = "prod-*-rg" }
]
```

Then use `not = true` to deny if name doesn't match any pattern:

```hcl
{
  anyOf = [
    { field = "name", like = "dev-*-rg" },
    { field = "name", like = "prod-*-rg" }
  ],
  not = true  # Deny if NOT matching any pattern
}
```

## Advanced: Different Patterns for Different Resource Types

```hcl
resource "azurerm_policy_definition" "naming_convention" {
  name         = "naming-convention"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Resource Naming Convention"

  policy_rule = jsonencode({
    if = {
      anyOf = [
        {
          allOf = [
            { field = "type", equals = "Microsoft.Resources/resourceGroups" },
            { field = "name", notLike = "*-*-rg" }
          ]
        },
        {
          allOf = [
            { field = "type", equals = "Microsoft.Storage/storageAccounts" },
            { field = "name", notLike = "*-*-sa" }
          ]
        },
        {
          allOf = [
            { field = "type", equals = "Microsoft.Compute/virtualMachines" },
            { field = "name", notLike = "*-*-vm" }
          ]
        }
      ]
    },
    then = {
      effect = "deny"
    }
  })
}
```

## Complete Example

**main.tf:**
```hcl
resource "azurerm_policy_definition" "resource_naming_convention" {
  name         = "resource-naming-convention"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Resource Naming Convention Policy"
  description  = "Enforces naming: env-resourcetype-rg"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type",
          equals = "Microsoft.Resources/resourceGroups"
        },
        {
          anyOf = [
            {
              field = "name",
              like = "dev-*-rg"
            },
            {
              field = "name",
              like = "staging-*-rg"
            },
            {
              field = "name",
              like = "prod-*-rg"
            }
          ],
          not = true
        }
      ]
    },
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "naming_convention" {
  name                 = "naming-convention-assignment"
  policy_definition_id = azurerm_policy_definition.resource_naming_convention.id
  subscription_id      = data.azurerm_subscription.current.id
}
```

## Testing

```bash
# Apply policy
terraform apply

# Test compliant names
terraform apply -target=azurerm_resource_group.test_compliant_dev
# ✅ Should succeed

# Test non-compliant names
terraform plan -target=azurerm_resource_group.test_noncompliant_1
# ❌ Should fail with policy violation
```

## Best Practices

1. **Document Patterns:** Clearly document allowed naming patterns
2. **Start Simple:** Begin with basic patterns, add complexity later
3. **Test Thoroughly:** Test various name combinations
4. **Use Variables:** Make patterns configurable if needed
5. **Provide Examples:** Include examples in policy description

## Common Naming Patterns

**Resource Groups:**
- `{env}-{app}-rg` → `dev-webapp-rg`
- `{env}-{team}-{project}-rg` → `prod-platform-api-rg`

**Storage Accounts:**
- `{env}{app}sa` → `devwebappsa`
- `{env}-{app}-sa` → `dev-webapp-sa`

**Virtual Machines:**
- `{env}-{role}-vm` → `prod-db-vm`
- `{env}-{app}-vm{number}` → `dev-web-vm01`

Choose patterns that are:
- Consistent
- Descriptive
- Easy to validate
- Support your organization's needs

