# Day 5 - CI/CD with GitHub Actions

## Overview
Learn to create CI/CD pipelines for Terraform using GitHub Actions, including automated testing, validation, and deployment.

## Learning Objectives
- Set up GitHub Actions workflows for Terraform
- Implement automated Terraform validation and formatting
- Create secure secret management in CI/CD
- Implement automated plan and apply workflows
- Use GitHub Actions for multi-environment deployments
- Understand Terraform Cloud integration

## Exercise: Complete CI/CD Pipeline

### Task
Create a comprehensive GitHub Actions workflow for Terraform deployments.

1. **Workflow Structure**
   Create workflows for:
   - Validation and formatting (on pull requests)
   - Plan (on pull requests to main)
   - Apply (on merge to main)
   - Destroy (manual workflow)

2. **Validation Workflow**
   - Run `terraform fmt -check`
   - Run `terraform validate`
   - Run `tflint` (optional)
   - Comment on PR with results

3. **Plan Workflow**
   - Run `terraform init`
   - Run `terraform plan`
   - Post plan output as PR comment
   - Store plan artifacts

4. **Apply Workflow**
   - Run `terraform init`
   - Run `terraform apply -auto-approve`
   - Post deployment status
   - Handle rollback on failure

5. **Secret Management**
   - Store Azure credentials as GitHub Secrets
   - Store Terraform variables as secrets
   - Use Azure service principal for authentication
   - Secure backend configuration

6. **Multi-Environment Support**
   - Support dev/staging/prod environments
   - Use environment-specific workflows
   - Use GitHub Environments for approvals
   - Environment-specific variable files

7. **Advanced Features**
   - Terraform Cloud integration
   - Cost estimation
   - Security scanning
   - Notifications (Slack, email)

### Requirements
- Secure credential management
- Proper error handling
- Artifact storage
- PR comments and status updates
- Environment protection rules

## Workflow Examples

### Basic Validation Workflow
```yaml
name: Terraform Validation
on:
  pull_request:
    paths:
      - '**.tf'
      - '**.tfvars'
```

### Plan Workflow
```yaml
name: Terraform Plan
on:
  pull_request:
    branches:
      - main
```

### Apply Workflow
```yaml
name: Terraform Apply
on:
  push:
    branches:
      - main
```

### Deliverables
- Complete GitHub Actions workflows
- Secret management documentation
- Multi-environment configuration
- Security best practices guide
- Troubleshooting guide
- Example repository structure

