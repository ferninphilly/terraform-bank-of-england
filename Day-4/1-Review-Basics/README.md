# Day 4 - Review: Terraform Basics

## Overview
This lesson reviews the fundamental concepts covered in Days 1-3, ensuring you have a solid foundation before moving to intermediate topics.

## Learning Objectives
- Review resource creation and provider configuration
- Review state management and backend configuration
- Review variable usage and type constraints
- Review directory structure best practices
- Review lifecycle rules and validation

## Exercise 1: Complete Infrastructure Setup

### Task
Create a complete, production-ready infrastructure setup that demonstrates all basic concepts:

1. **Provider Configuration**
   - Configure Azure provider with version constraints
   - Set up proper backend configuration for remote state

2. **Resource Group**
   - Create a resource group with proper naming convention
   - Add validation to ensure location is in allowed regions (eastus, westus, westeurope)

3. **Storage Account**
   - Create a storage account with:
     - Proper naming (lowercase, alphanumeric, max 24 chars)
     - Type constraints validation
     - Lifecycle rules (prevent destroy)
     - Tags from variables

4. **Variables**
   - Create variables.tf with:
     - Environment (dev/staging/prod)
     - Location with validation
     - Resource name prefix
     - Tags as map

5. **Locals**
   - Create locals.tf with:
     - Common tags
     - Resource naming convention
     - Environment-specific configurations

6. **Outputs**
   - Output resource group name
   - Output storage account name
   - Output storage account primary endpoint

### Requirements
- Use proper file structure (separate files for each component)
- Include type constraints on all variables
- Add validation rules
- Use lifecycle blocks appropriately
- Follow Azure naming conventions

### Deliverables
- Complete terraform configuration
- terraform.tfvars file with example values
- README documenting your setup

