# Day 5 - Advanced State Management

## Overview
Learn advanced state management techniques including state migration, workspace management, and state manipulation.

## Learning Objectives
- Understand Terraform state structure
- Migrate state between backends
- Use Terraform workspaces effectively
- Manipulate state safely
- Understand state locking mechanisms
- Use remote state data sources

## Exercise 1: State Migration

### Task
Migrate Terraform state between different backends and configurations.

1. **Backend Migration**
   - Start with local backend
   - Migrate to Azure backend
   - Migrate between Azure storage accounts
   - Use `terraform init -migrate-state`

2. **State File Structure**
   - Understand state file format
   - Identify resources in state
   - Understand resource addresses

3. **State Commands**
   - `terraform state list` - List all resources
   - `terraform state show` - Show resource details
   - `terraform state mv` - Move resources
   - `terraform state rm` - Remove resources
   - `terraform state pull` - Download state
   - `terraform state push` - Upload state

### Requirements
- Document migration process
- Verify state after migration
- Handle state conflicts
- Backup state before migration

## Exercise 2: Terraform Workspaces

### Task
Use Terraform workspaces to manage multiple environments.

1. **Workspace Creation**
   - Create workspaces: dev, staging, prod
   - Switch between workspaces
   - List all workspaces

2. **Workspace-Specific Configuration**
   - Use workspace name in resource naming
   - Create workspace-specific variables
   - Use `terraform.workspace` variable

3. **Workspace State Management**
   - Understand workspace state isolation
   - Use different state keys per workspace
   - Manage workspace state files

4. **Workspace Best Practices**
   - When to use workspaces vs separate directories
   - Workspace limitations
   - Alternative approaches

### Workspace Commands
```bash
terraform workspace new dev
terraform workspace select dev
terraform workspace list
terraform workspace show
terraform workspace delete dev
```

### Requirements
- Create multiple workspaces
- Deploy same configuration to different workspaces
- Use workspace-specific configurations
- Understand workspace state isolation

## Exercise 3: State Manipulation

### Task
Safely manipulate Terraform state for common scenarios.

1. **Moving Resources**
   - Rename resources in state
   - Move resources between modules
   - Handle resource address changes

2. **Removing Resources**
   - Remove resources from state (without destroying)
   - Handle orphaned resources
   - Clean up state file

3. **State Inspection**
   - Inspect state file structure
   - Find resource dependencies
   - Identify state issues

4. **State Backup and Recovery**
   - Backup state files
   - Restore from backup
   - Handle state corruption

### Requirements
- Practice state manipulation commands
- Document state changes
- Verify changes with terraform plan
- Understand when state manipulation is needed

## Exercise 4: Remote State Data Sources

### Task
Reference resources from other Terraform configurations using remote state.

1. **Remote State Configuration**
   - Configure remote state backend
   - Access state from other configurations

2. **Remote State Data Source**
   - Use `terraform_remote_state` data source
   - Access outputs from other state files
   - Handle state dependencies

3. **Cross-Configuration References**
   - Reference network from infrastructure state
   - Reference database from application state
   - Build dependencies between configurations

### Requirements
- Set up multiple Terraform configurations
- Use remote state data sources
- Reference outputs from other states
- Handle state dependencies

### Deliverables
- State migration examples
- Workspace configuration examples
- State manipulation scripts
- Remote state data source examples
- Best practices documentation

