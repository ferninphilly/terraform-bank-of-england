# Day 5 - Data Sources and Importing Existing Infrastructure

## Overview
Learn to pull existing data from Azure and import existing infrastructure into Terraform state.

## Learning Objectives
- Use data sources to query existing Azure resources
- Import existing infrastructure into Terraform
- Understand import limitations and best practices
- Use data sources for cross-resource references
- Query Azure resources dynamically

## Exercise 1: Data Sources

### Task
Use data sources to query and reference existing Azure resources.

1. **Subscription and Resource Group Data**
   - Query current subscription information
   - Query existing resource groups
   - Use subscription ID and tenant ID from data sources

2. **Network Data Sources**
   - Query existing VNets
   - Query existing subnets
   - Query existing NSGs
   - Use data sources to reference existing network infrastructure

3. **Compute Data Sources**
   - Query existing VM images
   - Query availability sets
   - Query existing VMs for reference

4. **Key Vault Data Sources**
   - Query existing Key Vaults
   - Read secrets from Key Vault
   - Use Key Vault secrets in other resources

5. **Dynamic Queries**
   - Use data sources with variables
   - Filter resources by tags
   - Query resources by name patterns

### Requirements
- Use data sources instead of hardcoding values
- Handle cases where resources don't exist
- Use data source outputs in resource configurations
- Document data source dependencies

## Exercise 2: Importing Existing Infrastructure

### Task
Import existing Azure resources into Terraform state.

1. **Preparation**
   - Identify resources to import
   - Document resource IDs
   - Create Terraform configuration matching existing resources

2. **Import Process**
   - Import a resource group
   - Import a storage account
   - Import a VNet and subnets
   - Import a VM

3. **Import Best Practices**
   - Use terraform import command
   - Verify state after import
   - Use terraform plan to check for drift
   - Handle import errors

4. **Import Script**
   - Create a script to import multiple resources
   - Use terraform import with resource addresses
   - Document import process

### Import Commands Reference
```bash
# Import resource group
terraform import azurerm_resource_group.example /subscriptions/.../resourceGroups/example

# Import storage account
terraform import azurerm_storage_account.example /subscriptions/.../storageAccounts/examplestorage

# Import VNet
terraform import azurerm_virtual_network.example /subscriptions/.../virtualNetworks/example-vnet
```

### Requirements
- Create matching Terraform configuration before import
- Verify imports with terraform plan
- Handle resource dependencies
- Document import process

## Exercise 3: Combining Data Sources and Imports

### Task
Use data sources to discover resources, then import related resources.

1. **Discovery**
   - Use data sources to find existing resources
   - Query resources by tags or naming patterns
   - Build a list of resources to import

2. **Selective Import**
   - Import only specific resources
   - Use data sources to reference non-imported resources
   - Mix imported and new resources

3. **State Management**
   - Understand state file structure
   - Use terraform state commands
   - Move resources in state
   - Remove resources from state

### Deliverables
- Examples of various data sources
- Imported infrastructure examples
- Import scripts/documentation
- Best practices guide
- Troubleshooting guide for common import issues

