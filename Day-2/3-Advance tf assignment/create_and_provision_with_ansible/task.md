# Task: Create and Provision Virtual Machine with Terraform and Ansible

This comprehensive guide walks you through creating an Azure Virtual Machine using Terraform and provisioning it with Ansible. You'll learn how to combine infrastructure-as-code with configuration management to create a fully automated deployment pipeline.

## Learning Objectives

By completing this task, you will learn:
- How to create Azure Virtual Machines with Terraform
- How to use Terraform provisioners (remote-exec and local-exec)
- How to integrate Ansible with Terraform for configuration management
- How to use ternary operators for conditional logic
- How to manage SSH keys for secure access
- How to create conditional provisioning based on variables
- Best practices for infrastructure and configuration management

## Prerequisites

Before starting, ensure you have:
- Azure subscription with appropriate permissions
- Terraform installed (version >= 1.9.0)
- Ansible installed (version >= 2.9.0)
- Azure CLI installed and configured
- SSH client installed
- Basic understanding of Terraform and Ansible

### Installing Ansible

**On macOS:**
```bash
brew install ansible
```

**On Linux:**
```bash
sudo apt-get update
sudo apt-get install ansible
# or
sudo yum install ansible
```

**On Windows (using WSL):**
```bash
sudo apt-get update
sudo apt-get install ansible
```

**Verify installation:**
```bash
ansible --version
```

---

## Step 1: Understanding the Project Structure

Let's examine the files in this project:

```
create_and_provision_with_ansible/
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable definitions
├── provider.tf         # Provider configuration
├── terraform.tfvars.example  # Example variable values
├── .gitignore          # Git ignore rules
├── ansible/
│   ├── playbook.yml    # Ansible playbook
│   └── requirements.txt # Ansible requirements
└── task.md             # This file
```

### File Overview

- **main.tf**: Contains all Azure resources (VM, network, security groups)
- **variables.tf**: Defines all configurable variables
- **provider.tf**: Configures Azure and Random providers
- **ansible/playbook.yml**: Ansible playbook for VM provisioning
- **terraform.tfvars.example**: Example configuration values

---

## Step 2: Understanding Variables and Ternary Operators

### Review variables.tf

Open `variables.tf` and examine the variables:

```hcl
variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

**Key Points:**
- **Type validation**: Ensures only valid environments are used
- **Default value**: Provides a sensible default
- **Description**: Documents the variable's purpose

### Understanding Ternary Operators

Terraform uses ternary operators for conditional logic. The syntax is:
```hcl
condition ? true_value : false_value
```

**Example from main.tf:**
```hcl
size = var.vm_size != "" ? var.vm_size : (
  var.environment == "prod" ? "Standard_B2ms" : (
    var.environment == "staging" ? "Standard_B2s" : "Standard_B1s"
  )
)
```

**Breaking this down:**
1. **First condition**: `var.vm_size != ""`
   - If `vm_size` is provided → use that value
   - If not → evaluate nested ternary

2. **Nested ternary**: `var.environment == "prod" ? "Standard_B2ms" : ...`
   - If prod → use `Standard_B2ms`
   - If not prod → check staging

3. **Final condition**: `var.environment == "staging" ? "Standard_B2s" : "Standard_B1s"`
   - If staging → use `Standard_B2s`
   - Otherwise (dev) → use `Standard_B1s`

**Result:**
- **Dev**: `Standard_B1s` (cheapest)
- **Staging**: `Standard_B2s` (medium)
- **Prod**: `Standard_B2ms` (more powerful)

---

## Step 3: Creating the Resource Group and Network

### Resource Group

```hcl
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
```

**What this does:**
- Creates a logical container for all resources
- Uses variables for name and location
- Applies tags for organization

### Virtual Network

```hcl
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.environment}-${random_id.suffix.hex}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
```

**Key Points:**
- **Naming**: Uses environment and random suffix for uniqueness
- **Address space**: `10.0.0.0/16` provides 65,536 IP addresses
- **Dependencies**: References resource group (implicit dependency)

### Subnet

```hcl
resource "azurerm_subnet" "main" {
  name                 = "subnet-${var.environment}"
  address_prefixes     = ["10.0.1.0/24"]
  # ... other attributes
}
```

**What this does:**
- Creates a subnet within the VNet
- Uses `/24` CIDR (256 IP addresses)
- Isolates VM network traffic

---

## Step 4: Network Security Group (NSG)

```hcl
resource "azurerm_network_security_group" "main" {
  # ... configuration
  
  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "22"
    source_address_prefix      = "*"
  }
  
  security_rule {
    name                       = "allow-http"
    priority                   = 110
    destination_port_range     = "80"
    # ... other attributes
  }
}
```

**Understanding NSG Rules:**
- **Priority**: Lower numbers evaluated first (100, 110, etc.)
- **Direction**: `Inbound` = traffic coming into Azure
- **Access**: `Allow` = permit traffic
- **Protocol**: `Tcp` = TCP protocol
- **Ports**: 
  - `22` = SSH (for Ansible and management)
  - `80` = HTTP (for nginx web server)

**Why we need these:**
- SSH (22): Required for Ansible to connect
- HTTP (80): Required for nginx web server

---

## Step 5: SSH Key Generation

```hcl
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
```

**What this does:**
- Generates a new SSH key pair
- Uses RSA algorithm with 4096 bits (secure)
- Creates both private and public keys

### Saving Keys Locally

```hcl
resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/.ssh/id_rsa"
  file_permission = "0600"
}
```

**Key Points:**
- **path.module**: Current module directory
- **file_permission**: `0600` = read/write for owner only (secure)
- **Purpose**: Ansible needs private key to connect

**Security Note:** Never commit private keys to Git! They're in `.gitignore`.

---

## Step 6: Creating the Virtual Machine

### VM Configuration

```hcl
resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm-${var.environment}-${random_id.suffix.hex}"
  size                = var.vm_size != "" ? var.vm_size : (
    var.environment == "prod" ? "Standard_B2ms" : (
      var.environment == "staging" ? "Standard_B2s" : "Standard_B1s"
    )
  )
  admin_username      = var.admin_username
  # ... other configuration
}
```

**Understanding the Size Logic:**
- Uses ternary operator to select VM size
- Environment-based defaults if `vm_size` not specified
- Cost-optimized: smaller VMs for dev, larger for prod

### OS Disk Configuration

```hcl
os_disk {
  caching              = "ReadWrite"
  storage_account_type = var.environment == "prod" ? "Premium_LRS" : "Standard_LRS"
}
```

**Ternary Operator Here:**
- **Prod**: Premium_LRS (faster, more expensive)
- **Dev/Staging**: Standard_LRS (slower, cheaper)

**Why:** Production needs better performance, dev/staging can use cheaper storage.

### Source Image

```hcl
source_image_reference {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
  version   = "latest"
}
```

**What this specifies:**
- **Publisher**: Canonical (Ubuntu)
- **Offer**: Ubuntu Server 22.04 (Jammy)
- **SKU**: LTS (Long Term Support) Gen2
- **Version**: Latest available

---

## Step 7: Understanding Terraform Provisioners

Terraform provisioners allow you to run scripts or commands during resource creation.

### Provisioner Types

1. **remote-exec**: Runs commands on the created resource
2. **local-exec**: Runs commands on your local machine

### Remote-Exec Provisioner

```hcl
provisioner "remote-exec" {
  inline = [
    "echo 'VM is ready for Ansible provisioning'",
    "sudo apt-get update",
  ]

  connection {
    type        = "ssh"
    user        = var.admin_username
    private_key = tls_private_key.ssh.private_key_pem
    host        = azurerm_public_ip.main.ip_address
  }
}
```

**What this does:**
- Runs commands **on the VM** after it's created
- Uses SSH connection
- Prepares VM for Ansible (updates package list)

**Connection Block:**
- **type**: SSH connection
- **user**: Username to connect as
- **private_key**: SSH private key for authentication
- **host**: Public IP address of the VM

### Local-Exec Provisioner

```hcl
provisioner "local-exec" {
  command = var.enable_ansible ? <<-EOT
    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
      -i ${azurerm_public_ip.main.ip_address}, \
      -u ${var.admin_username} \
      --private-key ${path.module}/.ssh/id_rsa \
      -e "ansible_python_interpreter=/usr/bin/python3" \
      -e "install_nginx=${var.install_nginx}" \
      -e "install_docker=${var.install_docker}" \
      ${var.ansible_playbook_path}
  EOT : "echo 'Ansible provisioning skipped'"
}
```

**Breaking this down:**

1. **Conditional execution**: `var.enable_ansible ? ... : ...`
   - If `enable_ansible` is true → run Ansible
   - If false → skip with echo message

2. **Heredoc syntax**: `<<-EOT ... EOT`
   - Multi-line string
   - Allows formatting across lines

3. **Ansible command components:**
   - `ANSIBLE_HOST_KEY_CHECKING=False`: Skip SSH host key checking
   - `-i ${azurerm_public_ip.main.ip_address},`: Inventory (IP address)
   - `-u ${var.admin_username}`: SSH user
   - `--private-key`: Path to SSH private key
   - `-e`: Extra variables passed to Ansible
   - Playbook path: Location of playbook file

**Why Local-Exec:**
- Runs Ansible from your machine
- Has access to playbook files
- Can use local Ansible installation

---

## Step 8: Understanding the Ansible Playbook

Open `ansible/playbook.yml`:

### Playbook Structure

```yaml
---
- name: Provision Azure VM with Ansible
  hosts: all
  become: yes
  gather_facts: yes
```

**Key Elements:**
- **name**: Description of the playbook
- **hosts: all**: Run on all hosts in inventory
- **become: yes**: Use sudo for privileged tasks
- **gather_facts: yes**: Collect system information

### Variables

```yaml
vars:
  install_nginx: "{{ install_nginx | default(true) | bool }}"
  install_docker: "{{ install_docker | default(false) | bool }}"
```

**What this does:**
- Defines variables with defaults
- `| bool`: Converts string to boolean
- Allows conditional installation

### Tasks

#### Task 1: Update Package Cache

```yaml
- name: Update apt cache
  apt:
    update_cache: yes
    cache_valid_time: 3600
```

**Purpose:** Refreshes package list before installing packages.

#### Task 2: Install Basic Packages

```yaml
- name: Install basic packages
  apt:
    name:
      - curl
      - wget
      - git
      # ... more packages
    state: present
```

**Purpose:** Installs essential tools needed on the VM.

#### Task 3: Conditional Nginx Installation

```yaml
- name: Install nginx (conditional)
  apt:
    name: nginx
    state: present
  when: install_nginx | bool
```

**Key Feature:** `when` clause makes task conditional
- Only runs if `install_nginx` is true
- Uses Ansible's conditional logic

#### Task 4: Create Custom Web Page

```yaml
- name: Create custom nginx index page
  copy:
    content: |
      <!DOCTYPE html>
      <html>
      <!-- HTML content -->
      </html>
    dest: /var/www/html/index.html
```

**Purpose:** Creates a custom web page to verify nginx is working.

#### Task 5: Conditional Docker Installation

```yaml
- name: Install Docker (conditional)
  block:
    - name: Add Docker GPG key
    - name: Add Docker repository
    - name: Install Docker
  when: install_docker | bool
```

**Key Feature:** `block` groups multiple tasks
- All tasks in block run if condition is true
- Useful for multi-step installations

---

## Step 9: Initializing and Planning

### Step 9.1: Create terraform.tfvars

Copy the example file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
environment          = "dev"
location             = "eastus"
resource_group_name  = "vm-ansible-rg"
enable_ansible       = true
install_nginx        = true
install_docker       = false
```

### Step 9.2: Initialize Terraform

```bash
terraform init
```

**What this does:**
- Downloads Azure provider
- Downloads Random provider
- Sets up backend (if configured)

**Expected Output:**
```
Initializing providers...
- Finding hashicorp/azurerm versions matching "~> 4.8.0"...
- Finding hashicorp/random versions matching "~> 3.1.0"...
- Installing hashicorp/azurerm v4.x.x...
- Installing hashicorp/random v3.x.x...
```

### Step 9.3: Review the Plan

```bash
terraform plan
```

**What to look for:**
- Resources to be created (should see ~10+ resources)
- VM size that will be used (check ternary operator result)
- Ansible provisioner will run (if enabled)

**Expected Output:**
```
Plan: 12 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ansible_status    = "Enabled"
  + ssh_command       = "ssh -i ..."
  + vm_public_ip      = (known after apply)
  + vm_size_used      = "Standard_B1s"
```

**Verify:**
- `vm_size_used` shows correct size for your environment
- `ansible_status` shows "Enabled" if `enable_ansible = true`

---

## Step 10: Applying the Configuration

### Step 10.1: Apply Terraform

```bash
terraform apply
```

Type `yes` when prompted, or use:
```bash
terraform apply -auto-approve
```

**What happens:**
1. **Resource Creation** (~5-10 minutes):
   - Resource group created
   - Network resources created
   - VM created and started
   - Public IP assigned

2. **Remote-Exec Provisioner** (~1-2 minutes):
   - SSH connection established
   - Commands run on VM
   - Package list updated

3. **Local-Exec Provisioner** (~2-5 minutes):
   - Ansible connects to VM
   - Playbook executed
   - Packages installed
   - Services configured

**Total Time:** ~10-15 minutes

### Step 10.2: Monitor the Output

Watch for:
- Resource creation progress
- SSH connection establishment
- Ansible playbook execution
- Task completion messages

**Expected Ansible Output:**
```
PLAY [Provision Azure VM with Ansible] ********************

TASK [Update apt cache] ***********************************
changed: [x.x.x.x]

TASK [Install basic packages] *****************************
changed: [x.x.x.x]

TASK [Install nginx (conditional)] ************************
changed: [x.x.x.x]

PLAY RECAP *************************************************
x.x.x.x  : ok=8  changed=7  unreachable=0  failed=0
```

---

## Step 11: Verifying the Deployment

### Step 11.1: Check Outputs

```bash
terraform output
```

**Expected Output:**
```
vm_public_ip = "x.x.x.x"
vm_private_ip = "10.0.1.x"
ssh_command = "ssh -i .ssh/id_rsa azureuser@x.x.x.x"
vm_size_used = "Standard_B1s"
ansible_status = "Enabled"
```

### Step 11.2: Test SSH Connection

```bash
# Use the output command
terraform output -raw ssh_command

# Or manually
ssh -i .ssh/id_rsa azureuser@<vm_public_ip>
```

**Verify:**
- SSH connection works
- You can log into the VM
- Ansible marker file exists: `ls /tmp/ansible_provisioned`

### Step 11.3: Test Nginx (if installed)

```bash
# From your local machine
curl http://<vm_public_ip>
```

**Expected:** HTML page showing "Hello from Ansible!"

**Or open in browser:**
```
http://<vm_public_ip>
```

### Step 11.4: Verify Installed Software

SSH into the VM and check:

```bash
# Check nginx
systemctl status nginx
nginx -v

# Check Docker (if installed)
docker --version
systemctl status docker

# Check installed packages
dpkg -l | grep -E "nginx|docker"
```

---

## Step 12: Understanding Conditional Provisioning

### Testing with Different Configurations

#### Test 1: Disable Ansible

Edit `terraform.tfvars`:
```hcl
enable_ansible = false
```

Apply:
```bash
terraform apply
```

**Result:** VM created, but Ansible doesn't run. You'll see:
```
local-exec: echo 'Ansible provisioning skipped'
```

#### Test 2: Enable Docker

Edit `terraform.tfvars`:
```hcl
install_docker = true
```

Apply:
```bash
terraform apply
```

**Result:** Ansible installs Docker in addition to nginx.

#### Test 3: Change Environment

Edit `terraform.tfvars`:
```hcl
environment = "prod"
```

Plan:
```bash
terraform plan
```

**Result:** VM size changes to `Standard_B2ms` (larger, more expensive).

---

## Step 13: Cleanup

When finished testing:

```bash
terraform destroy
```

**This will:**
- Delete the VM
- Delete network resources
- Delete resource group
- **Keep**: SSH keys (local files)

**To also remove SSH keys:**
```bash
rm -rf .ssh/
```

---

## Key Concepts Summary

### Ternary Operators

**Syntax:**
```hcl
condition ? true_value : false_value
```

**Nested Example:**
```hcl
var.environment == "prod" ? "large" : (
  var.environment == "staging" ? "medium" : "small"
)
```

**Use Cases:**
- Environment-based resource sizing
- Conditional storage types
- Feature flags
- Cost optimization

### Terraform Provisioners

**Remote-Exec:**
- Runs on the created resource
- Uses SSH/WinRM connection
- Good for: Initial setup, preparing for configuration management

**Local-Exec:**
- Runs on your local machine
- Good for: Running external tools (Ansible, scripts)
- Can use local files and tools

**Best Practices:**
- Use provisioners sparingly
- Prefer configuration management tools (Ansible, Chef, Puppet)
- Handle failures gracefully
- Consider null_resource for complex provisioning

### Ansible Integration

**Why Ansible + Terraform:**
- **Terraform**: Infrastructure provisioning
- **Ansible**: Configuration management
- **Separation of Concerns**: Infrastructure vs. configuration

**Integration Methods:**
1. **Local-exec provisioner** (this task)
2. **Ansible dynamic inventory**
3. **Terraform + Ansible in CI/CD pipeline**

---

## Troubleshooting

### Issue: SSH Connection Failed

**Symptoms:** Provisioner fails to connect

**Solutions:**
1. **Check NSG rules:**
   ```bash
   az network nsg rule list --nsg-name <nsg-name> --resource-group <rg-name>
   ```
   Ensure port 22 is allowed

2. **Check public IP:**
   ```bash
   terraform output vm_public_ip
   ```
   Verify IP is assigned

3. **Wait for VM:**
   - VM needs time to boot
   - Wait 2-3 minutes after creation

4. **Check SSH key:**
   ```bash
   ls -la .ssh/id_rsa
   ```
   Verify key file exists and has correct permissions (600)

### Issue: Ansible Playbook Fails

**Symptoms:** Ansible tasks fail

**Solutions:**
1. **Check Ansible installation:**
   ```bash
   ansible --version
   ```

2. **Test SSH manually:**
   ```bash
   ssh -i .ssh/id_rsa azureuser@<vm_public_ip>
   ```

3. **Run Ansible manually:**
   ```bash
   ansible-playbook -i <vm_ip>, -u azureuser --private-key .ssh/id_rsa ansible/playbook.yml
   ```

4. **Check Ansible logs:**
   - Review output for specific error
   - Check task that failed

### Issue: VM Size Not Correct

**Symptoms:** Wrong VM size used

**Solutions:**
1. **Check variable:**
   ```bash
   terraform console
   > var.environment
   > var.vm_size
   ```

2. **Verify ternary logic:**
   - Review `main.tf` VM size logic
   - Check environment variable value

3. **Override explicitly:**
   ```hcl
   vm_size = "Standard_B2s"  # Override in terraform.tfvars
   ```

### Issue: Nginx Not Accessible

**Symptoms:** Can't access web page

**Solutions:**
1. **Check NSG rule:**
   - Ensure port 80 is allowed
   - Check rule priority

2. **Check nginx status:**
   ```bash
   ssh -i .ssh/id_rsa azureuser@<vm_ip>
   sudo systemctl status nginx
   ```

3. **Check firewall:**
   ```bash
   sudo ufw status
   ```

4. **Check nginx config:**
   ```bash
   sudo nginx -t
   ```

---

## Best Practices

1. **Use Variables:** Make everything configurable
2. **Validate Inputs:** Use validation blocks
3. **Tag Resources:** Organize with tags
4. **Secure Keys:** Never commit private keys
5. **Idempotency:** Ensure Ansible playbooks are idempotent
6. **Error Handling:** Handle provisioner failures
7. **Documentation:** Document complex logic
8. **Testing:** Test in dev before prod

---

## Questions for Reflection

Answer these questions to reinforce your learning:

### Question 1: Ternary Operators
**Explain what this ternary operator does:**
```hcl
storage_account_type = var.environment == "prod" ? "Premium_LRS" : "Standard_LRS"
```

**Answer:** 
- If environment is "prod" → use Premium_LRS
- Otherwise → use Standard_LRS
- Purpose: Use faster storage for production, cheaper for dev/staging

### Question 2: Provisioner Execution Order
**In what order do these provisioners execute?**
```hcl
provisioner "remote-exec" { ... }
provisioner "local-exec" { ... }
```

**Answer:**
- `remote-exec` runs first (on VM)
- `local-exec` runs second (on local machine)
- Order matters: remote-exec prepares VM, local-exec runs Ansible

### Question 3: Conditional Ansible Execution
**How does this conditional work?**
```hcl
command = var.enable_ansible ? "ansible-playbook ..." : "echo 'Skipped'"
```

**Answer:**
- If `enable_ansible` is true → run ansible-playbook command
- If false → run echo command (skip Ansible)
- Allows enabling/disabling Ansible without code changes

### Question 4: Nested Ternary Operators
**What VM size will be used if:**
- `var.environment = "staging"`
- `var.vm_size = ""`

**Answer:**
- `Standard_B2s`
- Logic: vm_size is empty, so check environment. Staging → B2s

### Question 5: Ansible Conditional Tasks
**In the Ansible playbook, what does this do?**
```yaml
- name: Install nginx
  apt:
    name: nginx
  when: install_nginx | bool
```

**Answer:**
- Only installs nginx if `install_nginx` variable is true
- `| bool` converts string to boolean
- Allows conditional package installation

### Question 6: SSH Key Security
**Why is the file permission `0600` important for the private key?**

**Answer:**
- `0600` = read/write for owner only
- Prevents other users from reading the key
- Required for SSH security
- Prevents unauthorized access

### Question 7: Provisioner Dependencies
**Why does the VM resource have `depends_on` for the network interface?**

**Answer:**
- Ensures network interface exists before VM creation
- VM needs network interface to connect
- Prevents creation errors
- Explicit dependency management

### Question 8: Ansible Inventory
**In the local-exec provisioner, what does `-i ${azurerm_public_ip.main.ip_address},` mean?**

**Answer:**
- `-i` = inventory (list of hosts)
- IP address is the target host
- Trailing comma makes it a valid inventory format
- Tells Ansible which host to connect to

### Question 9: Cost Optimization
**How do ternary operators help with cost optimization?**

**Answer:**
- Use smaller/cheaper resources for dev
- Use larger/more expensive for prod
- Automatically select based on environment
- Reduces manual configuration errors

### Question 10: Idempotency
**Why is it important that Ansible playbooks are idempotent?**

**Answer:**
- Can run multiple times safely
- Won't cause errors if run again
- Ensures consistent state
- Prevents duplicate installations

---

## Advanced Exercises

### Exercise 1: Add More Conditional Logic
Add a variable `install_monitoring` and conditionally install monitoring tools (Prometheus, Grafana) via Ansible.

### Exercise 2: Multi-Environment Support
Create separate `terraform.tfvars` files for dev, staging, and prod with different configurations.

### Exercise 3: Add More VM Sizes
Extend the ternary operator to support more VM sizes based on a `vm_tier` variable (small, medium, large).

### Exercise 4: Ansible Roles
Refactor the Ansible playbook to use roles instead of inline tasks.

### Exercise 5: Error Handling
Add error handling to provisioners to handle failures gracefully.

---

## Summary

In this task, you learned:
- ✅ How to create Azure VMs with Terraform
- ✅ How to use ternary operators for conditional logic
- ✅ How to integrate Ansible with Terraform
- ✅ How to use provisioners (remote-exec and local-exec)
- ✅ How to manage SSH keys securely
- ✅ How to create conditional provisioning
- ✅ Best practices for infrastructure and configuration management

**Next Steps:**
- Experiment with different configurations
- Try the advanced exercises
- Explore more Ansible modules
- Learn about Terraform modules for reusability

---

## Additional Resources

- [Terraform Provisioners Documentation](https://www.terraform.io/docs/language/resources/provisioners/syntax.html)
- [Ansible Documentation](https://docs.ansible.com/)
- [Azure VM Sizes](https://docs.microsoft.com/azure/virtual-machines/sizes)
- [Terraform Ternary Operators](https://www.terraform.io/docs/language/expressions/conditionals.html)

