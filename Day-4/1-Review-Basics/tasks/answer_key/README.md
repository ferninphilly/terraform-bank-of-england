# Answer Key - Day 4 Review Basics

This directory contains complete answer keys for both review tasks.

## Directory Structure

```
answer_key/
├── task1-vm-setup/          # Complete VM setup Terraform configuration
│   ├── provider.tf
│   ├── variables.tf
│   ├── rg.tf
│   ├── network.tf
│   ├── vm.tf
│   ├── output.tf
│   ├── terraform.tfvars.example
│   └── README.md
│
└── task2-authentication/    # Azure authentication scripts and examples
    ├── set_vars.sh
    ├── verify_auth.sh
    ├── test_auth.tf
    └── README.md
```

## Task 1: VM Setup

Complete Terraform configuration for creating a Virtual Machine with network infrastructure.

**Location:** `task1-vm-setup/`

**What's included:**
- Full Terraform configuration files
- Variables with validation
- Network components (VNet, Subnet, Public IP, NSG, NIC)
- Linux VM configuration
- Outputs for easy access to information
- Example terraform.tfvars file

**See:** `task1-vm-setup/README.md` for usage instructions

## Task 2: Azure Authentication

Scripts and examples for authenticating Terraform with Azure on Linux.

**Location:** `task2-authentication/`

**What's included:**
- `set_vars.sh` - Automatically sets environment variables from Service Principal JSON
- `verify_auth.sh` - Verifies authentication configuration
- `test_auth.tf` - Test Terraform configuration to verify authentication

**See:** `task2-authentication/README.md` for detailed usage instructions

## Usage

These answer keys are reference implementations. Students should:

1. **Try the tasks first** using the review guides:
   - `setup_vm_task_review.md`
   - `azure_authentication_linux_review.md`

2. **Compare with answer keys** after attempting the tasks

3. **Understand the differences** between their solution and the answer key

4. **Ask questions** about any concepts that are unclear

## Notes

- These are complete, working examples
- They follow Terraform best practices
- They include proper validation and error handling
- They are suitable for learning and reference

## Prerequisites

Before using these answer keys, ensure:

1. **For Task 1:**
   - Azure authentication configured (Task 2)
   - SSH key pair generated
   - Terraform installed

2. **For Task 2:**
   - Azure CLI installed
   - Terraform installed
   - jq installed (for scripts)
   - Active Azure subscription

