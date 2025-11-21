# Creating Terraform Modules - VM with Ansible

This project demonstrates how to convert VM creation and Ansible provisioning code into a reusable Terraform module.

## Quick Start

1. **Configure Variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review Plan:**
   ```bash
   terraform plan
   ```

4. **Apply Configuration:**
   ```bash
   terraform apply
   ```

5. **Access Your VM:**
   ```bash
   terraform output ssh_command
   ```

## Project Structure

```
creating_modules_in_terraform/
├── main.tf                    # Root module - calls child modules
├── variables.tf               # Root module variables
├── outputs.tf                 # Root module outputs
├── provider.tf                # Provider configuration
├── terraform.tfvars.example   # Example variable values
├── task.md                    # Detailed step-by-step guide
└── modules/                   # Child modules directory
    ├── vm-with-ansible/      # VM creation module
    │   ├── main.tf           # Module resources
    │   ├── variables.tf      # Module variables
    │   ├── outputs.tf        # Module outputs
    │   └── ansible/          # Ansible playbook
    │       └── playbook.yml
    └── alerts/               # VM monitoring module
        ├── main.tf           # Alert resources
        ├── variables.tf      # Alert variables
        ├── outputs.tf        # Alert outputs
        └── README.md         # Module documentation
```

## Key Concepts

- **Module**: Reusable container for Terraform resources
- **Module Call**: Using `module` block to instantiate a module
- **Variable Passing**: Passing values from root to module
- **Module Outputs**: Accessing module values via `module.name.output`
- **Module Dependencies**: One module using outputs from another module
- **Reusability**: Create multiple VMs with same module, different configs
- **Module Composition**: Building complex infrastructure with multiple modules

## Key Features

- ✅ Environment-based VM sizing (dev/staging/prod)
- ✅ Conditional Ansible provisioning
- ✅ SSH key generation and management
- ✅ Network security group configuration
- ✅ Conditional package installation (nginx, docker)
- ✅ Ternary operators for cost optimization
- ✅ **VM Monitoring and Alerts** (CPU, memory, disk, network, availability)
- ✅ **Module Dependencies** (alerts module uses VM module outputs)
- ✅ Comprehensive documentation

## Learn More

See [task.md](./task.md) for comprehensive step-by-step instructions explaining:
- What modules are and why to use them
- How to convert code into a module
- How to call and use modules
- How modules can depend on other modules
- How to create monitoring and alerting modules
- How to create multiple instances
- Best practices and troubleshooting

