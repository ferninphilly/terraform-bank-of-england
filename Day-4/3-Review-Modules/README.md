# Day 4 - Review: Modules

## Overview
Review module creation and usage concepts from Day 3.

## Learning Objectives
- Review module structure and best practices
- Review module inputs and outputs
- Review module dependencies
- Review module versioning

## Exercise: Reusable Storage Module

### Task
Create a reusable storage account module and use it in multiple scenarios.

1. **Module Structure**
   - Create `modules/storage-account/` directory
   - Include: main.tf, variables.tf, outputs.tf
   - Follow module best practices

2. **Module Features**
   - Configurable storage account tier and replication
   - Support for different access tiers
   - Configurable blob properties
   - Lifecycle management rules
   - Tags support

3. **Module Usage**
   - Use the module to create storage accounts for:
     - Application data (hot tier)
     - Backup storage (cool tier)
     - Archive storage (archive tier)

4. **Module Outputs**
   - Storage account name
   - Primary connection string (sensitive)
   - Primary blob endpoint
   - Storage account ID

### Requirements
- Module should be reusable and configurable
- Include proper variable validation
- Use outputs to expose necessary information
- Document module usage

### Deliverables
- Complete module structure
- Root module using the storage module
- Example terraform.tfvars
- Module README with usage examples

