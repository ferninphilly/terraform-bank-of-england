# Day 5 - Intermediate Terraform Concepts

## Overview
Day 5 introduces intermediate Terraform concepts that will help you build production-ready, maintainable infrastructure. You'll learn advanced patterns, best practices, and tools that extend Terraform's capabilities.

## Learning Path

### 1. GitHub Modules
**Directory**: `Github-Modules/`

Learn to publish and use Terraform modules from GitHub:
- Publishing modules to GitHub
- Module versioning and releases
- Using modules from remote sources
- Module documentation and best practices
- Module composition and inheritance

**Exercise**: Publish a VM module to GitHub and use it in your Terraform configurations.

### 2. Conditional Creation and For_Each
**Directory**: `2-Conditional-ForEach/`

Master dynamic resource creation:
- Conditional resource creation with `count`
- `for_each` loops with custom maps
- Dynamic permissions and configurations
- Combining conditionals with loops

**Exercise**: Create infrastructure that conditionally creates resources and uses for_each for dynamic configurations.

### 3. Data Sources and Importing
**Directory**: `3-Data-Sources-Import/`

Work with existing infrastructure:
- Query existing Azure resources
- Import existing infrastructure into Terraform
- Use data sources for cross-resource references
- Handle import limitations

**Exercise**: Query existing resources and import infrastructure into Terraform state.

### 4. State Management
**Directory**: `4-State-Management/`

Master Terraform state:
- State migration between backends
- Terraform workspaces
- State manipulation commands
- Remote state data sources

**Exercise**: Migrate state, use workspaces, and reference remote state.

### 5. Terragrunt
**Directory**: `5-Terragrunt/`

Learn Terragrunt for DRY configurations:
- Terragrunt installation and setup
- Configuration inheritance
- Multi-environment management
- Terragrunt hooks

**Exercise**: Set up multi-environment infrastructure using Terragrunt.

### 6. CI/CD with GitHub Actions
**Directory**: `6-CICD-GitHub-Actions/`

Automate Terraform deployments:
- GitHub Actions workflows
- Automated validation and planning
- Secure secret management
- Multi-environment deployments

**Exercise**: Create complete CI/CD pipeline for Terraform.

### 7. Advanced Concepts
**Directory**: `7-Advanced-Concepts/`

Explore advanced Terraform features:
- Null resources and provisioners
- Advanced functions and expressions
- Secret management best practices
- External data sources

**Exercise**: Implement advanced patterns and secret management.

### 8. Terraform Tests
**Directory**: `8-Terraform-Tests/`

Learn Terraform's built-in testing framework:
- Write test files for Terraform configurations
- Test resource creation and attributes
- Test module outputs and behaviors
- Validate conditional resources
- Integrate tests into CI/CD pipelines

**Exercise**: Create comprehensive tests for infrastructure configurations and validate them.

## Objectives

By the end of Day 5, you will be able to:
- ✅ Create reusable, composable Terraform modules
- ✅ Conditionally create resources and use for_each effectively
- ✅ Query and import existing infrastructure
- ✅ Manage Terraform state across environments
- ✅ Use Terragrunt for DRY configurations
- ✅ Set up CI/CD pipelines for Terraform
- ✅ Implement advanced Terraform patterns
- ✅ Manage secrets securely in Terraform
- ✅ Write and run tests for Terraform configurations

## Prerequisites

Before starting Day 5, ensure you have:
- Completed Day 4 review exercises
- Strong understanding of basic Terraform concepts
- Terraform version >= 1.6.0 (required for testing framework in exercise 8)
- GitHub account (for CI/CD exercises)
- Understanding of Git and version control
- Basic knowledge of CI/CD concepts

## Getting Started

1. **Start with GitHub Modules** (`Github-Modules/`) - Learn to publish and use modules from GitHub
2. **Learn Conditionals** (`2-Conditional-ForEach/`) - Essential for dynamic infrastructure
3. **Master Data Sources** (`3-Data-Sources-Import/`) - Work with existing resources
4. **Understand State** (`4-State-Management/`) - Critical for production
5. **Explore Terragrunt** (`5-Terragrunt/`) - Optional but powerful
6. **Automate with CI/CD** (`6-CICD-GitHub-Actions/`) - Production requirement
7. **Advanced Topics** (`7-Advanced-Concepts/`) - Expand your toolkit
8. **Test Your Infrastructure** (`8-Terraform-Tests/`) - Ensure quality and correctness

## Key Concepts Covered

### Modules
- Composition over inheritance
- Input/output contracts
- Module versioning
- Cross-module dependencies

### Dynamic Resources
- `count` vs `for_each`
- Conditional creation patterns
- Map-based configurations
- Complex iteration scenarios

### State Management
- State file structure
- Backend migration
- Workspace isolation
- Remote state references

### CI/CD
- Automated validation
- Secure deployments
- Environment management
- Approval workflows

### Advanced Patterns
- Null resources for triggers
- Provisioners (when appropriate)
- Secret management
- External integrations

### Testing
- Terraform test framework
- Test file structure
- Resource and output validation
- CI/CD test integration

## Best Practices

1. **Use modules for reusability** - Don't repeat yourself
2. **Prefer for_each over count** - More flexible and maintainable
3. **Manage state carefully** - Always backup before changes
4. **Automate everything** - CI/CD is essential for production
5. **Secure secrets** - Never commit secrets to version control
6. **Document everything** - Future you will thank present you
7. **Test your code** - Write tests to validate infrastructure before deployment
8. **Test incrementally** - Build and test in small steps

## Common Pitfalls to Avoid

1. **Over-engineering modules** - Keep them simple and focused
2. **Ignoring state management** - State is critical
3. **Hardcoding values** - Use variables and data sources
4. **Skipping validation** - Catch errors early
5. **Poor secret management** - Security is paramount
6. **Not using CI/CD** - Manual deployments are error-prone
7. **Not writing tests** - Tests catch issues before production

## Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform Testing Documentation](https://developer.hashicorp.com/terraform/language/testing)

## Next Steps

After completing Day 5, you'll be ready to:
- Build production-ready Terraform configurations
- Manage complex multi-environment infrastructure
- Automate infrastructure deployments
- Work with existing infrastructure
- Implement best practices in your organization

Consider exploring:
- Terraform Cloud/Enterprise
- Advanced module patterns
- Policy as Code (Sentinel)
- Advanced testing strategies (integration tests, contract testing)
- Cost optimization techniques

