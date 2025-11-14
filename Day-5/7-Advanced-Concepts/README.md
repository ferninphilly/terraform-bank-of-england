# Day 5 - Advanced Terraform Concepts

## Overview
Explore advanced Terraform concepts including null resources, provisioners, advanced functions, and secret management.

## Learning Objectives
- Use null resources for custom logic
- Understand provisioners and their use cases
- Implement advanced Terraform functions
- Manage secrets securely in Terraform
- Use external data sources
- Understand Terraform Cloud features

## Exercise 1: Null Resources and Provisioners

### Task
Use null resources and provisioners for custom automation.

1. **Null Resources**
   - Create null resources for custom triggers
   - Use triggers to force resource recreation
   - Combine with local-exec provisioner

2. **Local-Exec Provisioner**
   - Run local scripts after resource creation
   - Use provisioners for post-deployment tasks
   - Handle provisioner failures

3. **Remote-Exec Provisioner**
   - Execute commands on remote resources
   - Configure VMs after creation
   - Use SSH/WinRM for remote access

4. **File Provisioner**
   - Copy files to remote resources
   - Upload configuration files
   - Deploy application files

### Requirements
- Use null resources appropriately
- Handle provisioner failures
- Understand provisioner limitations
- Document provisioner use cases

## Exercise 2: Advanced Functions and Expressions

### Task
Use advanced Terraform functions for complex logic.

1. **Collection Functions**
   - `flatten()`, `setproduct()`, `zipmap()`
   - Transform complex data structures
   - Combine multiple collections

2. **String Functions**
   - `regex()`, `regexall()`, `replace()`
   - Parse and transform strings
   - Extract data from strings

3. **Type Conversion**
   - `tostring()`, `tonumber()`, `tobool()`
   - Convert between types
   - Handle type mismatches

4. **Advanced Expressions**
   - Ternary operators
   - Complex conditionals
   - Nested function calls

### Requirements
- Demonstrate advanced function usage
- Show practical applications
- Handle edge cases
- Document function combinations

## Exercise 3: Secret Management

### Task
Implement secure secret management in Terraform.

1. **Azure Key Vault Integration**
   - Store secrets in Key Vault
   - Retrieve secrets using data sources
   - Use Key Vault secrets in resources

2. **Sensitive Variables**
   - Mark variables as sensitive
   - Handle sensitive outputs
   - Prevent secret exposure in logs

3. **External Secret Management**
   - Integrate with HashiCorp Vault
   - Use environment variables
   - Secure backend configuration

4. **Secret Rotation**
   - Handle secret updates
   - Implement secret rotation strategies
   - Update resources when secrets change

### Requirements
- Never commit secrets to version control
- Use proper secret management tools
- Mark sensitive data appropriately
- Document secret management process

## Exercise 4: External Data Sources

### Task
Use external data sources for dynamic data.

1. **External Data Source**
   - Execute external scripts
   - Parse script output as JSON
   - Use external data in resources

2. **HTTP Data Source**
   - Query REST APIs
   - Fetch data from external services
   - Handle API responses

3. **TLS Data Source**
   - Get TLS certificate information
   - Validate certificates
   - Use certificate data

### Requirements
- Handle external data source failures
- Cache external data appropriately
- Validate external data
- Document external dependencies

### Deliverables
- Null resource and provisioner examples
- Advanced function demonstrations
- Secret management implementation
- External data source examples
- Best practices documentation

