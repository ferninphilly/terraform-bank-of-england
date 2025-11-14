# Day 5 - Terragrunt and Extendable Terraform Tools

## Overview
Learn to use Terragrunt, a thin wrapper around Terraform that provides extra tools for working with multiple Terraform modules.

## Learning Objectives
- Understand Terragrunt and its benefits
- Configure Terragrunt for DRY (Don't Repeat Yourself) principles
- Use Terragrunt for environment management
- Understand Terragrunt hooks
- Compare Terragrunt with native Terraform approaches

## Exercise: Multi-Environment Infrastructure with Terragrunt

### Task
Set up a multi-environment infrastructure using Terragrunt to eliminate code duplication.

1. **Terragrunt Installation**
   - Install Terragrunt
   - Verify installation
   - Understand Terragrunt version requirements

2. **Terragrunt Structure**
   Create the following structure:
   ```
   terragrunt/
   ├── terragrunt.hcl (root configuration)
   ├── environments/
   │   ├── dev/
   │   │   └── terragrunt.hcl
   │   ├── staging/
   │   │   └── terragrunt.hcl
   │   └── prod/
   │       └── terragrunt.hcl
   └── modules/
       └── infrastructure/
           ├── main.tf
           ├── variables.tf
           └── outputs.tf
   ```

3. **Root Terragrunt Configuration**
   - Configure remote state
   - Set common variables
   - Define provider configuration
   - Use `generate` blocks for DRY

4. **Environment-Specific Configuration**
   - Inherit from root configuration
   - Override environment-specific values
   - Use `dependency` blocks for module dependencies
   - Configure environment-specific backends

5. **Terragrunt Features**
   - Use `include` for configuration inheritance
   - Use `dependency` blocks for cross-module references
   - Use `before_hook` and `after_hook` for automation
   - Use `generate` blocks for dynamic file generation

6. **Terragrunt Commands**
   - `terragrunt init`
   - `terragrunt plan`
   - `terragrunt apply`
   - `terragrunt destroy`
   - `terragrunt run-all plan` (apply to all modules)
   - `terragrunt run-all apply`

### Requirements
- Eliminate code duplication using Terragrunt
- Support multiple environments (dev/staging/prod)
- Use dependency management
- Implement hooks for automation
- Document Terragrunt structure

## Advanced: Terragrunt Hooks

### Task
Use Terragrunt hooks for automation and validation.

1. **Before Hooks**
   - Validate Azure CLI authentication
   - Check prerequisites
   - Run custom scripts

2. **After Hooks**
   - Send notifications
   - Update documentation
   - Run post-deployment scripts

3. **Error Hooks**
   - Handle failures gracefully
   - Send alerts
   - Cleanup on failure

### Deliverables
- Complete Terragrunt structure
- Root terragrunt.hcl configuration
- Environment-specific configurations
- Terragrunt hooks examples
- Documentation comparing Terragrunt vs native Terraform
- Migration guide from Terraform to Terragrunt

