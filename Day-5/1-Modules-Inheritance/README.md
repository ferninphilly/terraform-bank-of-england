# Day 5 - Modules and Inheritance

## Overview
Learn to create reusable, composable Terraform modules with proper inheritance patterns and variable replacement.

## Learning Objectives
- Create reusable modules with proper structure
- Implement module inheritance and composition
- Use variable replacement and defaults effectively
- Understand module versioning and dependencies
- Create module outputs for cross-module communication

## Exercise: Multi-Tier Application Module

### Task
Create a comprehensive module system for deploying a multi-tier application infrastructure.

1. **Base Module: Network**
   - Create `modules/network/` module
   - VNet with configurable subnets
   - Network Security Groups
   - Route tables
   - Outputs: VNet ID, Subnet IDs, NSG IDs

2. **Composed Module: Compute**
   - Create `modules/compute/` module
   - Accepts network module outputs as inputs
   - Creates VMs in appropriate subnets
   - Uses network security groups from network module
   - Outputs: VM IDs, Private IPs

3. **Composed Module: Database**
   - Create `modules/database/` module
   - Accepts network module outputs
   - Creates database in private subnet
   - Uses NSG from network module
   - Outputs: Database connection strings (sensitive)

4. **Root Module Composition**
   - Use all three modules together
   - Pass outputs between modules
   - Implement proper dependencies

### Requirements
- Each module should be independently testable
- Use variable defaults for common configurations
- Implement proper variable validation
- Use outputs to pass data between modules
- Include module READMEs with usage examples

### Advanced: Module Inheritance
- Create a base module with common configurations
- Create environment-specific modules that inherit from base
- Use module composition to build complex infrastructure

### Deliverables
- Complete module structure (network, compute, database)
- Root module using all modules
- Module documentation
- Example terraform.tfvars
- Demonstration of module outputs and dependencies

