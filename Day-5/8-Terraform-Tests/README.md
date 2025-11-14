# Day 5 - Terraform Tests

## Overview
Learn to write and run tests for your Terraform configurations using Terraform's built-in testing framework. This ensures your infrastructure code works correctly before deployment.

## Learning Objectives
- Understand Terraform's testing framework
- Write test files for Terraform configurations
- Test resource creation and attributes
- Test module outputs and behaviors
- Run tests and interpret results
- Integrate tests into CI/CD pipelines

## Prerequisites
- Terraform version >= 1.6.0 (required for testing framework)
- Completed previous Day 5 exercises (we'll test infrastructure from earlier exercises)

## Exercise: Testing Terraform Infrastructure

### Task
Create comprehensive tests for Terraform configurations to validate infrastructure before deployment.

1. **Test File Structure**
   - Create test files with `.tftest.hcl` extension
   - Understand test blocks and assertions
   - Organize tests logically

2. **Basic Resource Tests**
   - Test resource creation
   - Validate resource attributes
   - Test resource dependencies
   - Verify resource naming conventions

3. **Module Tests**
   - Test module outputs
   - Validate module behavior
   - Test module with different inputs
   - Verify module dependencies

4. **Advanced Testing**
   - Test conditional resource creation
   - Test for_each resources
   - Test data sources
   - Test error conditions

5. **Integration with CI/CD**
   - Run tests in GitHub Actions
   - Fail builds on test failures
   - Generate test reports

### Requirements
- Use Terraform 1.6.0 or later
- Write tests for at least 3 different resource types
- Test both positive and negative cases
- Document test coverage
- Integrate tests into CI/CD workflow

## Test Framework Overview

### Test File Structure
Test files use the `.tftest.hcl` extension and contain `run` blocks:

```hcl
run "test_name" {
  command = plan  # or apply

  assert {
    condition     = <condition>
    error_message = "Error message if test fails"
  }
}
```

### Test Commands
- `plan` - Test the plan phase
- `apply` - Test the apply phase (creates real resources)

### Assertions
- `condition` - Boolean expression to evaluate
- `error_message` - Message shown if assertion fails

## Example Test Scenarios

### 1. Resource Existence Test
```hcl
run "resource_group_exists" {
  command = plan

  assert {
    condition     = azurerm_resource_group.example != null
    error_message = "Resource group should be created"
  }
}
```

### 2. Attribute Validation
```hcl
run "storage_account_naming" {
  command = plan

  assert {
    condition     = length(azurerm_storage_account.example.name) <= 24
    error_message = "Storage account name must be 24 characters or less"
  }
}
```

### 3. Output Validation
```hcl
run "outputs_correct" {
  command = plan

  assert {
    condition     = output.resource_group_name == "rg-example"
    error_message = "Output should match expected value"
  }
}
```

### 4. Conditional Resource Test
```hcl
run "conditional_resource_created" {
  command = plan

  variables {
    create_vnet = true
  }

  assert {
    condition     = azurerm_virtual_network.example != null
    error_message = "VNet should be created when create_vnet is true"
  }
}
```

## Running Tests

### Run All Tests
```bash
terraform test
```

### Run Specific Test File
```bash
terraform test tests/main.tftest.hcl
```

### Verbose Output
```bash
terraform test -verbose
```

## Best Practices

1. **Test Early and Often**
   - Write tests as you develop
   - Test before committing code

2. **Test Critical Paths**
   - Focus on important resources
   - Test error conditions

3. **Keep Tests Fast**
   - Use `plan` command when possible
   - Use `apply` only when necessary

4. **Clear Assertions**
   - Write descriptive error messages
   - Test one thing per assertion

5. **Organize Tests**
   - Group related tests
   - Use descriptive test names

## Deliverables
- Test files for infrastructure from previous exercises
- Tests covering resource creation, attributes, and outputs
- Tests for conditional resources
- CI/CD integration for automated testing
- Test documentation and coverage report

