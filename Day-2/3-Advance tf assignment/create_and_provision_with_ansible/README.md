# Create and Provision VM with Terraform and Ansible

This project demonstrates how to create an Azure Virtual Machine using Terraform and provision it with Ansible for configuration management.

## Quick Start

1. **Prerequisites:**
   ```bash
   # Install Terraform
   brew install terraform  # macOS
   # or download from https://www.terraform.io/downloads
   
   # Install Ansible
   brew install ansible  # macOS
   # or: sudo apt-get install ansible  # Linux
   ```

2. **Configure Variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Initialize and Apply:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Access Your VM:**
   ```bash
   # Get SSH command
   terraform output ssh_command
   
   # Or manually
   ssh -i .ssh/id_rsa azureuser@<vm_public_ip>
   ```

5. **Test Web Server:**
   ```bash
   # Get public IP
   terraform output vm_public_ip
   
   # Test nginx
   curl http://<vm_public_ip>
   ```

## Project Structure

```
create_and_provision_with_ansible/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── provider.tf                # Provider configuration
├── terraform.tfvars.example  # Example variable values
├── task.md                    # Detailed step-by-step guide
├── ansible/
│   ├── playbook.yml          # Ansible playbook
│   └── requirements.txt      # Ansible requirements
└── README.md                 # This file
```

## Key Features

- ✅ Environment-based VM sizing (dev/staging/prod)
- ✅ Conditional Ansible provisioning
- ✅ SSH key generation and management
- ✅ Network security group configuration
- ✅ Conditional package installation (nginx, docker)
- ✅ Ternary operators for cost optimization
- ✅ Comprehensive documentation

## Learn More

See [task.md](./task.md) for detailed step-by-step instructions and explanations.

