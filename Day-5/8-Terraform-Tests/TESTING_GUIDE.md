# Terraform Testing Guide

## Overview

Terraform's built-in testing framework (introduced in Terraform 1.6.0) allows you to write tests for your infrastructure code. Tests help ensure your configurations work correctly before deployment.

## Prerequisites

- Terraform version >= 1.6.0
- Azure provider configured
- Test infrastructure code to validate

## Test File Structure

### File Naming
- Test files use the `.tftest.hcl` extension
- Place test files in a `tests/` directory
- Organize tests by functionality

### Test Block Structure
```hcl
run "test_name" {
  command = plan  # or apply

  variables {
    # Optional: override variables for this test
  }

  assert {
    condition     = <boolean_expression>
    error_message = "Descriptive error message"
  }

  # Multiple assertions allowed
  assert {
    condition     = <another_condition>
    error_message = "Another error message"
  }
}
```

## Test Commands

### Plan Command
Tests the planning phase without creating resources:
```hcl
run "test_plan" {
  command = plan
  # ...
}
```

### Apply Command
Tests the apply phase (creates real resources):
```hcl
run "test_apply" {
  command = apply
  # ...
}
```

**Warning**: `apply` tests create real resources and may incur costs. Use with caution.

## Running Tests

### Run All Tests
```bash
terraform test
```

### Run Specific Test File
```bash
terraform test tests/basic-resources.tftest.hcl
```

### Verbose Output
```bash
terraform test -verbose
```

### Filter Tests
```bash
terraform test -filter="resource_group"
```

## Test Examples

### 1. Resource Existence
```hcl
run "resource_exists" {
  command = plan

  assert {
    condition     = azurerm_resource_group.example != null
    error_message = "Resource group should exist"
  }
}
```

### 2. Attribute Validation
```hcl
run "name_validation" {
  command = plan

  assert {
    condition     = length(azurerm_storage_account.example.name) <= 24
    error_message = "Name must be 24 characters or less"
  }
}
```

### 3. Output Validation
```hcl
run "output_correct" {
  command = plan

  assert {
    condition     = output.resource_group_name == "rg-example"
    error_message = "Output should match expected value"
  }
}
```

### 4. Conditional Resources
```hcl
run "conditional_resource" {
  command = plan

  variables {
    create_vnet = true
  }

  assert {
    condition     = length(azurerm_virtual_network.example) == 1
    error_message = "VNet should be created"
  }
}
```

### 5. Variable Overrides
```hcl
run "custom_variables" {
  command = plan

  variables {
    location = "westus"
    environment = "production"
  }

  assert {
    condition     = azurerm_resource_group.example.location == "westus"
    error_message = "Location should be westus"
  }
}
```

## Best Practices

### 1. Test Organization
- Group related tests in the same file
- Use descriptive test names
- Separate tests by functionality

### 2. Test Coverage
- Test critical resources
- Test error conditions
- Test edge cases
- Test outputs

### 3. Performance
- Prefer `plan` over `apply` when possible
- Use `apply` only for integration tests
- Keep tests fast

### 4. Assertions
- One assertion per concern
- Clear error messages
- Test both positive and negative cases

### 5. Maintenance
- Update tests when code changes
- Remove obsolete tests
- Document complex test logic

## Common Test Patterns

### Testing Resource Attributes
```hcl
assert {
  condition     = azurerm_resource_group.example.location == var.location
  error_message = "Location should match variable"
}
```

### Testing Resource Dependencies
```hcl
assert {
  condition     = azurerm_storage_account.example.resource_group_name == azurerm_resource_group.example.name
  error_message = "Storage account should be in the resource group"
}
```

### Testing Conditional Creation
```hcl
assert {
  condition     = var.create_vnet ? length(azurerm_virtual_network.example) == 1 : length(azurerm_virtual_network.example) == 0
  error_message = "VNet creation should match variable"
}
```

### Testing Tags
```hcl
assert {
  condition     = azurerm_resource_group.example.tags["Environment"] == var.environment
  error_message = "Environment tag should match variable"
}
```

## CI/CD Integration

### GitHub Actions Example
```yaml
- name: Run Terraform Tests
  run: terraform test
```

### Fail on Test Failure
```yaml
- name: Run Terraform Tests
  run: terraform test || exit 1
```

### Test with Different Variables
```yaml
- name: Test Dev Environment
  run: terraform test -var-file=dev.tfvars

- name: Test Prod Environment
  run: terraform test -var-file=prod.tfvars
```

## Troubleshooting

### Test Failures
1. Check error messages - they're descriptive
2. Verify Terraform version >= 1.6.0
3. Ensure test files have `.tftest.hcl` extension
4. Check variable values in test blocks

### Common Issues
- **"Unknown resource"**: Resource not in configuration
- **"Invalid assertion"**: Check condition syntax
- **"Variable not found"**: Define variable in variables.tf

## Advanced Testing

### Testing Modules
Test modules by referencing them:
```hcl
module "test_module" {
  source = "./modules/example"
  # ...
}

run "module_output" {
  command = plan

  assert {
    condition     = module.test_module.output_value == "expected"
    error_message = "Module output should match"
  }
}
```

### Testing Data Sources
```hcl
data "azurerm_resource_group" "example" {
  name = "existing-rg"
}

run "data_source" {
  command = plan

  assert {
    condition     = data.azurerm_resource_group.example != null
    error_message = "Data source should return data"
  }
}
```

## Resources

- [Terraform Testing Documentation](https://developer.hashicorp.com/terraform/language/testing)
- [Terraform Test Command](https://developer.hashicorp.com/terraform/cli/commands/test)

