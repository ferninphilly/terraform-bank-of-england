# Day 5 - Conditional Creation and For_Each Loops

## Overview
Learn to conditionally create resources and use for_each loops with custom maps for dynamic resource management.

## Learning Objectives
- Use count and for_each for resource iteration
- Implement conditional resource creation
- Create and use custom maps for dynamic configurations
- Combine conditionals with loops for complex scenarios
- Understand when to use count vs for_each

## Exercise 1: Conditional Networking

### Task
Create a networking infrastructure that conditionally creates resources based on environment and requirements.

1. **Conditional Resource Creation**
   - Create a VNet only if `create_vnet = true`
   - Create a VPN Gateway only if `create_vpn = true`
   - Create a NAT Gateway only if `create_nat = true`
   - Use `count` for simple conditionals

2. **Environment-Based Configuration**
   - Dev: Minimal networking (VNet only)
   - Staging: VNet + NAT Gateway
   - Prod: VNet + NAT Gateway + VPN Gateway

3. **Conditional Subnets**
   - Create subnets based on a list
   - Use for_each to create subnets dynamically
   - Conditionally associate NSG based on subnet type

### Requirements
- Use variables to control resource creation
- Implement proper dependencies
- Handle cases where resources don't exist
- Use outputs conditionally

## Exercise 2: For_Each with Custom Maps

### Task
Create multiple resources using for_each with custom maps for configuration.

1. **Custom Map Structure**
   Create a map of storage accounts with different configurations:
   ```hcl
   storage_accounts = {
     "app-data" = {
       tier             = "Standard"
       replication_type = "LRS"
       access_tier      = "Hot"
     }
     "backup" = {
       tier             = "Standard"
       replication_type = "GRS"
       access_tier      = "Cool"
     }
     "archive" = {
       tier             = "Standard"
       replication_type = "ZRS"
       access_tier      = "Archive"
     }
   }
   ```

2. **For_Each Implementation**
   - Use for_each to create storage accounts from the map
   - Access map values using `each.value`
   - Use `each.key` for resource naming

3. **Complex Maps**
   - Create a map of VMs with different configurations
   - Include networking, size, and image information
   - Use for_each to create all VMs

4. **Combining Conditionals and Loops**
   - Only create certain resources if conditions are met
   - Use for_each with conditional logic
   - Filter maps based on conditions

### Requirements
- Use for_each (not count) for map-based resources
- Create comprehensive custom maps
- Handle map lookups and transformations
- Use locals to transform maps if needed

## Exercise 3: Dynamic Permissions with For_Each

### Task
Create role assignments using for_each with a map of permissions.

1. **Permission Map**
   Create a map defining roles for different service principals:
   ```hcl
   role_assignments = {
     "sp-app" = {
       role_definition_name = "Contributor"
       scope               = "/subscriptions/..."
     }
     "sp-reader" = {
       role_definition_name = "Reader"
       scope               = "/subscriptions/..."
     }
   }
   ```

2. **For_Each Role Assignments**
   - Use for_each to create role assignments
   - Handle different scopes and roles
   - Use data sources to get principal IDs

3. **Conditional Permissions**
   - Only assign certain roles in production
   - Use conditionals within for_each blocks
   - Create permission sets based on environment

### Deliverables
- Complete conditional resource creation examples
- For_each implementations with custom maps
- Dynamic permission assignments
- Documentation explaining count vs for_each usage
- Example terraform.tfvars files

