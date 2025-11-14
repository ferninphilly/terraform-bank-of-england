# Day 4 - Review: Advanced Basics

## Overview
Review advanced basic concepts including string manipulation, networking, and complex resource configurations.

## Learning Objectives
- Review Terraform functions and string manipulation
- Review networking concepts (VNet, Subnets, NSG)
- Review dynamic blocks and complex configurations
- Review Azure AD integration

## Exercise: Multi-Environment Network Infrastructure

### Task
Create a comprehensive network infrastructure that can be deployed across multiple environments.

1. **Network Infrastructure**
   - Create a VNet with multiple subnets
   - Use dynamic blocks for NSG rules
   - Implement proper naming using string functions

2. **String Manipulation**
   - Use `lower()`, `replace()`, `substr()` for resource naming
   - Create a naming module using locals
   - Format tags using string functions

3. **Dynamic Blocks**
   - Create NSG with dynamic security rules
   - Rules should be configurable via variables
   - Use for_each for multiple rules

4. **Network Security**
   - Create Network Security Group
   - Allow SSH (port 22) from specific IP ranges
   - Allow HTTP/HTTPS (ports 80, 443) from internet
   - Deny all other inbound traffic

5. **Outputs**
   - VNet ID
   - Subnet IDs
   - NSG ID
   - Formatted network information

### Requirements
- Use string functions for all naming
- Implement dynamic blocks for NSG rules
- Use variables for network configuration
- Support multiple environments (dev/staging/prod)
- Include proper validation

### Deliverables
- Complete network configuration
- terraform.tfvars with example values
- Documentation of network architecture

