# Day 4 - Review: Terraform Fundamentals

## Overview
Day 4 provides a comprehensive review of the fundamental Terraform concepts covered in Days 1-3. This day ensures you have a solid foundation before moving to intermediate topics in Day 5. Each section includes detailed review guides and hands-on tasks with complete answer keys.

## Learning Path

### 1. Review Basics
**Directory**: `1-Review-Basics/`

Review core Terraform concepts with practical exercises:

#### Task 1: Virtual Machine Setup
**File**: `tasks/setup_vm_task_review.md`

Learn to create a complete Azure VM infrastructure:
- Resource Group creation and explanation
- Virtual Network (VNet) and Subnet configuration
- Public IP Address allocation
- Network Security Group (NSG) with security rules
- Network Interface Card (NIC) configuration
- Linux Virtual Machine creation
- Backend configuration for remote state
- Variables, outputs, and best practices

**Answer Key**: `tasks/answer_key/task1-vm-setup/`

#### Task 2: Azure Authentication on Linux
**File**: `tasks/azure_authentication_linux_review.md`

Master Terraform authentication with Azure:
- Service Principal creation and configuration
- Environment variables for authentication
- Subscription ID explanation (plain English)
- Authentication verification scripts
- Security best practices
- Troubleshooting authentication issues

**Answer Key**: `tasks/answer_key/task2-authentication/`

**Key Concepts Covered**:
- Provider configuration and version constraints
- Resource creation and dependencies
- State management and backend configuration (Azure Storage)
- Variables, locals, and outputs
- Type constraints and validation
- Lifecycle rules
- Azure authentication methods

---

### 2. Review Advanced
**Directory**: `2-Review-Advanced/`

Review advanced Terraform concepts with comprehensive guides:

#### Review Guide 1: Variables Deep Dive
**File**: `variable_review.md`

Comprehensive guide covering:
- Variable types (string, number, bool, list, map, object, set, tuple)
- Variable hierarchy and precedence
- Variable assignment methods (CLI, files, environment)
- Variable validation rules
- Sensitive variables
- Variable scoping
- Advanced patterns and best practices

#### Review Guide 2: for_each and Dynamic Blocks
**File**: `for_each_and_variables_review.md`

In-depth exploration of:
- `for_each` meta-argument with maps and sets
- Comparison with `count` meta-argument
- Dynamic blocks for complex configurations
- Using `for_each` with variables
- Advanced patterns and transformations
- Common use cases and troubleshooting

#### Exercise: Network Infrastructure with for_each
**Task**: Create a comprehensive network infrastructure using `for_each` and dynamic blocks

**Requirements**:
- VNet with multiple subnets (using `for_each`)
- Network Security Group with dynamic security rules
- Conditional NSG associations
- String manipulation and naming conventions
- Map transformations using locals
- Comprehensive outputs

**Answer Key**: `answer_key/`

**Key Concepts Covered**:
- Terraform functions and string manipulation
- Networking concepts (VNet, Subnets, NSG)
- Dynamic blocks for complex configurations
- `for_each` meta-argument
- Variable types and complex data structures
- Map transformations and filtering

---

### 3. Review Modules
**Directory**: `3-Review-Modules/`

Review module concepts with progressively complex examples:

#### Task 1: Module Basics
**File**: `module_basics_task.md`

Start with a simple module to understand fundamentals:
- Module structure and best practices
- Module inputs (variables) and outputs
- Module dependencies
- Code reuse principles
- Module versioning concepts

**Answer Key**: `answer_key/` (Resource Group module)

#### Task 2: VM Module with Alerts
**File**: `vm_module_with_alerts_task.md`

Build a comprehensive VM module with monitoring:
- VM module with networking (VNet, Subnet, Public IP, NSG, NIC, VM)
- Configurable VM sizes and parameters
- Alerts module for monitoring
- Action Groups for notifications
- CPU and Memory metric alerts
- Activity log alerts
- Module dependencies and composition

**Answer Key**: `answer_key_vm/`

#### Task 3: MSSQL Database Module (Banking System)
**File**: `mssql_database_task.md`

Create a production-ready database module:
- MSSQL Server creation
- Multiple databases configuration
- Firewall rules (Azure services)
- SQL script execution using `null_resource` and provisioners
- Banking-focused schema (Customers, Accounts, Transactions, Loans)
- Stored procedures (GetCustomerAccounts, ProcessTransaction, TransferFunds)
- Database initialization scripts
- Module structure for database infrastructure

**Answer Key**: `answer_key_db/`

**Key Concepts Covered**:
- Module structure and best practices
- Module inputs and outputs
- Module dependencies and composition
- Module versioning
- Provisioners and `null_resource`
- SQL script execution with Terraform
- Complex module patterns

---

## Objectives

By the end of Day 4, you should be able to:
- ✅ Configure Terraform providers and backends (Azure Storage)
- ✅ Create and manage Azure resources with Terraform (VMs, Networks, Databases)
- ✅ Use variables, locals, and outputs effectively
- ✅ Implement validation and lifecycle rules
- ✅ Use Terraform functions for string manipulation
- ✅ Understand variable types, hierarchy, and precedence
- ✅ Use `for_each` and dynamic blocks for complex configurations
- ✅ Create and use Terraform modules (simple to complex)
- ✅ Execute SQL scripts using Terraform provisioners
- ✅ Structure Terraform code following best practices
- ✅ Authenticate Terraform with Azure (Service Principal, environment variables)

## Prerequisites

Before starting Day 4, ensure you have:
- Completed Days 1-3 exercises
- Azure subscription and CLI configured
- Terraform installed (version >= 1.5.0)
- Basic understanding of Azure resources
- `sqlcmd` installed (optional, for MSSQL task)

## Getting Started

1. **Start with `1-Review-Basics/`** to reinforce core concepts
   - Complete VM setup task
   - Master Azure authentication

2. **Move to `2-Review-Advanced/`** for advanced patterns
   - Read variable review guide
   - Read for_each and dynamic blocks guide
   - Complete network infrastructure exercise

3. **Complete `3-Review-Modules/`** for module understanding
   - Start with basic module task
   - Progress to VM module with alerts
   - Finish with MSSQL database module

Each exercise includes:
- Detailed review guides with explanations
- Step-by-step task instructions
- Complete answer keys with working code
- Best practices and requirements
- Troubleshooting guides

## Tips for Success

1. **Read the review guides first** - They provide essential context and explanations
2. **Complete tasks in order** - Each builds on previous concepts
3. **Compare with answer keys** - Learn from complete, working examples
4. **Experiment** - Try variations and see what happens
5. **Read error messages** - Terraform provides helpful feedback
6. **Use documentation** - Azure provider docs are your friend
7. **Understand the "why"** - Don't just copy code, understand the concepts

## Answer Keys

All tasks include complete answer keys located in `answer_key/` directories:
- **Basics**: `1-Review-Basics/tasks/answer_key/`
- **Advanced**: `2-Review-Advanced/answer_key/`
- **Modules**: `3-Review-Modules/answer_key/`, `answer_key_vm/`, `answer_key_db/`

Answer keys include:
- Complete Terraform configurations
- Example `terraform.tfvars` files
- Comprehensive README documentation
- Best practices and explanations

## Next Steps

After completing Day 4, you'll be ready for Day 5, which covers:
- Advanced modules and inheritance
- Conditional creation and advanced `for_each` patterns
- Data sources and importing existing resources
- Advanced state management
- Terragrunt for DRY configurations
- CI/CD with GitHub Actions
- Advanced Terraform concepts and patterns
