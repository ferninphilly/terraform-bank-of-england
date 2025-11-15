# Terraform Expression Day10 Practice Task

## Background
In this task, you'll work with a virtual machine deployment in Azure using different types of Terraform expressions. You'll create Network Security Group rules, implement conditional naming, and use splat expressions for outputs.

## Task Requirements

### 1. Dynamic Expressions with Local Values
- Create a local value block that defines NSG rules with the following properties:
  - One rule for SSH (port 22)
  - One rule for HTTP (port 80)
  - One rule for HTTPS (port 443)
- Each rule should include:
  - Priority
  - Direction (Inbound)
  - Access (Allow)
  - Protocol (Tcp)
  - Source port ranges (*)
  - Destination port ranges (respective ports)
  - Source address prefix (*)
  - Destination address prefix (*)
- Use these local values to create the Network Security Group rules for a VM

### 2. Conditional Expressions
- Create a Network Security Group with a dynamic name based on environment
- Requirements:
  - If var.environment is "dev", NSG name should be "nsg-dev-vm"
  - For any other environment value, NSG name should be "nsg-stage-vm"
  - Use a conditional expression to implement this logic

### 3. Splat Expression
- Create outputs that:
  - Show all NSG rule names using splat expression
  - Display the source port ranges for all rules using splat expression
  - List all the priorities of the security rules using splat expression

## Bonus Challenge
- Add a conditional expression that only creates HTTP and HTTPS rules if the environment is "stage"
- Output the count of security rules using a splat expression
