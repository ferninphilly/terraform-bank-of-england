# Day 4 - Review: Terraform Basics

## Overview
This lesson reviews the fundamental concepts covered in Days 1-3, ensuring you have a solid foundation before moving to intermediate topics. The review includes hands-on tasks with step-by-step guides and complete answer keys.

## Learning Objectives
- Review resource creation and provider configuration
- Review state management and backend configuration
- Review variable usage and type constraints
- Review directory structure best practices
- Review lifecycle rules and validation
- Master Azure authentication for Terraform
- Create complete VM infrastructure with networking

## Tasks

### Task 1: Virtual Machine Setup with Networking
**File**: `tasks/setup_vm_task_review.md`

**Comprehensive step-by-step guide** for creating a complete Azure Virtual Machine infrastructure:

**What You'll Learn:**
- Provider configuration and version constraints
- Resource Group creation and explanation
- Virtual Network (VNet) and Subnet configuration
- Public IP Address allocation
- Network Security Group (NSG) with security rules
- Network Interface Card (NIC) configuration
- Linux Virtual Machine creation
- Backend configuration for remote state (Azure Storage)
- Variables, outputs, and best practices

**Key Concepts:**
- Understanding Azure VM architecture and component dependencies
- Network security and firewall rules
- SSH key authentication
- Resource naming conventions
- Tag management

**Deliverables:**
- Complete Terraform configuration for VM with networking
- Backend configuration for state management
- Example variables file
- Complete answer key available in `tasks/answer_key/task1-vm-setup/`

---

### Task 2: Azure Authentication on Linux
**File**: `tasks/azure_authentication_linux_review.md`

**Essential authentication guide** for using Terraform with Azure on Linux machines:

**What You'll Learn:**
- Service Principal creation and configuration
- Environment variables for Terraform authentication
- Subscription ID explanation (plain English)
- Authentication verification methods
- Helper scripts for credential management
- Security best practices
- Troubleshooting authentication issues

**Key Concepts:**
- Service Principal vs Azure CLI authentication
- Environment variable configuration (`ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`)
- Subscription ID understanding
- Credential persistence and security
- Authentication verification scripts

**Deliverables:**
- Complete authentication setup
- Helper scripts (`set_vars.sh`, `verify_auth.sh`)
- Test configuration
- Complete answer key available in `tasks/answer_key/task2-authentication/`

---

### Task 3: Terraform Backend with Azure Storage
**File**: `tasks/terraform_backend_azure_storage_review.md`

**Comprehensive guide** for configuring Terraform remote state in Azure Storage Account (blob container):

**What You'll Learn:**
- Understanding Terraform state and why remote state matters
- Azure Storage Account and Blob Container concepts
- Creating storage account and container for state files
- Configuring Terraform backend (`azurerm` backend)
- State migration from local to remote
- State locking and conflict prevention
- Backend configuration options and best practices

**Key Concepts:**
- Local state vs Remote state
- Azure Storage Account (the "bucket" equivalent)
- Blob Container (container for state files)
- State file key (path/filename)
- State locking mechanism
- Team collaboration with shared state

**What Gets Created:**
- Azure Storage Account (for storing state)
- Blob Container (named `tfstate`)
- State file in Azure Storage
- Backend configuration in Terraform

**Deliverables:**
- Complete backend configuration
- Storage account setup instructions
- State migration guide
- Best practices for state management

**Important Terms:**
- **Storage Account** = Azure's storage service (like AWS S3 bucket)
- **Blob Container** = Container within storage account (like a folder)
- **State File Key** = Path/filename for your state file

---

## Prerequisites

Before starting these tasks, ensure you have:
- Terraform installed (version >= 1.5.0)
- Azure CLI installed and configured
- An Azure subscription
- SSH key pair generated (for Task 1)
- Linux machine (for Task 2)

## Getting Started

1. **Start with Task 2** (Authentication) - Essential foundation
   - Complete Azure authentication setup
   - Verify authentication works
   - Understand Service Principal concepts

2. **Complete Task 3** (Backend Configuration) - State management
   - Set up Azure Storage Account for state
   - Configure Terraform backend
   - Understand remote state concepts

3. **Complete Task 1** (VM Setup) - Apply your knowledge
   - Create complete VM infrastructure
   - Understand networking components
   - Use remote state backend

## Answer Keys

Complete answer keys are available in `tasks/answer_key/`:
- **Task 1**: `tasks/answer_key/task1-vm-setup/` - Complete VM configuration with backend
- **Task 2**: `tasks/answer_key/task2-authentication/` - Authentication scripts and examples
- **Task 3**: See `tasks/terraform_backend_azure_storage_review.md` for complete examples

Each answer key includes:
- Complete Terraform files
- Example variable files
- Helper scripts
- Comprehensive README documentation

## Key Concepts Covered

### Infrastructure as Code
- Terraform configuration structure
- Resource dependencies
- State management

### Azure Networking
- Virtual Networks and Subnets
- Network Security Groups
- Public and Private IPs
- Network Interfaces

### Authentication & Security
- Service Principal authentication
- Secure credential management
- Environment variables
- SSH key authentication

### State Management
- Local vs Remote state
- Azure Storage Account backend
- Blob Container configuration
- State locking and collaboration
- State migration

### Best Practices
- File organization
- Variable validation
- Output management
- Remote state backends
- State file organization

