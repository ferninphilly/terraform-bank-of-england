# Step-by-Step Guide: Azure Authentication for Terraform on Linux

This comprehensive guide walks you through authenticating Terraform with Azure on a Linux machine using a Service Principal. This is the recommended and most secure method for production environments.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Step 0: Install VS Code Terraform Extensions](#step-0-install-vs-code-terraform-extensions-recommended)
3. [Understanding Authentication Methods](#understanding-authentication-methods)
4. [Step 1: Install Required Tools](#step-1-install-required-tools)
5. [Step 2: Verify Installation](#step-2-verify-installation)
6. [Step 3: Log in to Azure CLI](#step-3-log-in-to-azure-cli)
7. [Step 4: Set Active Subscription](#step-4-set-active-subscription)
8. [Step 5: Create Service Principal](#step-5-create-service-principal)
9. [Step 6: Understand Service Principal Output](#step-6-understand-service-principal-output)
10. [Step 7: Configure Environment Variables](#step-7-configure-environment-variables)
11. [Step 8: Verify Authentication](#step-8-verify-authentication)
12. [Step 9: Persist Environment Variables](#step-9-persist-environment-variables)
13. [Step 10: Using Helper Scripts](#step-10-using-helper-scripts)
14. [Troubleshooting](#troubleshooting)
15. [Security Best Practices](#security-best-practices)

---

## Prerequisites

Before starting, ensure you have:
- A Linux machine (Ubuntu, Debian, RHEL, CentOS, etc.)
- An active Azure subscription
- Administrative/sudo access to install software
- Internet connectivity
- A web browser (for authentication)
- VS Code installed (recommended for editing Terraform files)

---

## Step 0: Install VS Code Terraform Extensions (Recommended)

VS Code (Visual Studio Code) is a popular code editor that provides excellent support for Terraform through extensions. Installing Terraform extensions will give you syntax highlighting, auto-completion, formatting, and validation, making your Terraform development much easier.

### Why Use VS Code Extensions?

- **Syntax Highlighting**: Makes Terraform code easier to read
- **Auto-completion**: Suggests resource types, attributes, and values as you type
- **Formatting**: Automatically formats your code to follow best practices
- **Validation**: Catches errors before you run `terraform plan`
- **IntelliSense**: Provides documentation and examples inline
- **HCL Language Support**: Full support for HashiCorp Configuration Language

### Required Extension: HashiCorp Terraform

The official HashiCorp Terraform extension provides the core functionality.

#### Installation Steps:

1. **Open VS Code**
   - Launch Visual Studio Code on your Linux machine

2. **Open Extensions View**
   - Click the Extensions icon in the left sidebar (looks like four squares)
   - Or press `Ctrl+Shift+X` (Linux/Windows) or `Cmd+Shift+X` (Mac)
   - Or go to View → Extensions

   ![VS Code Extensions Icon](screenshots/vscode-extensions-icon.png)
   *Screenshot: VS Code sidebar showing the Extensions icon*

3. **Search for Terraform Extension**
   - In the search box at the top, type: `HashiCorp Terraform`
   - Look for the extension published by **HashiCorp**

   ![Terraform Extension Search](screenshots/vscode-terraform-search.png)
   *Screenshot: Search results showing "HashiCorp Terraform" extension*

4. **Install the Extension**
   - Click the **Install** button on the HashiCorp Terraform extension
   - Wait for the installation to complete

   ![Terraform Extension Install](screenshots/vscode-terraform-install.png)
   *Screenshot: Terraform extension page showing Install button*

5. **Verify Installation**
   - After installation, the Install button will change to a gear icon
   - You may need to reload VS Code (it will prompt you)
   - Open a `.tf` file to see syntax highlighting

   ![Terraform Extension Installed](screenshots/vscode-terraform-installed.png)
   *Screenshot: Terraform extension showing as installed with gear icon*

### Recommended Extensions

While the HashiCorp Terraform extension is essential, these additional extensions can enhance your workflow:

#### 1. Azure Terraform (Optional but Recommended)

- **Name**: `Azure Terraform`
- **Publisher**: Microsoft
- **Why**: Provides Azure-specific snippets and IntelliSense for Azure resources

**Installation:**
- Search for `Azure Terraform` in the Extensions marketplace
- Install the extension published by Microsoft

![Azure Terraform Extension](screenshots/vscode-azure-terraform.png)
*Screenshot: Azure Terraform extension in VS Code*

#### 2. Terraform Doc (Optional)

- **Name**: `Terraform Doc`
- **Why**: Generates documentation from Terraform code

**Installation:**
- Search for `Terraform Doc` in Extensions
- Install to enable documentation generation

### Verifying Extensions Work

1. **Create a Test File**
   ```bash
   mkdir -p ~/terraform-test
   cd ~/terraform-test
   code test.tf
   ```

2. **Add Some Terraform Code**
   ```hcl
   terraform {
     required_providers {
       azurerm = {
         source  = "hashicorp/azurerm"
         version = "~> 3.0"
       }
     }
   }
   
   provider "azurerm" {
     features {}
   }
   ```

3. **Check for Features**
   - You should see syntax highlighting (keywords in different colors)
   - Hover over `azurerm` to see documentation
   - Type `resource "azurerm` and you should see auto-completion suggestions
   - Right-click and select "Format Document" to format the file

   ![Terraform Syntax Highlighting](screenshots/vscode-terraform-syntax.png)
   *Screenshot: Terraform file with syntax highlighting and IntelliSense*

### VS Code Settings for Terraform

You can configure VS Code to work better with Terraform:

1. **Open Settings**
   - Press `Ctrl+,` (Linux/Windows) or `Cmd+,` (Mac)
   - Or go to File → Preferences → Settings

2. **Search for Terraform Settings**
   - Type `terraform` in the settings search box
   - Configure options like:
     - `terraform.formatOnSave`: Automatically format Terraform files when saving
     - `terraform.format.enable`: Enable Terraform formatting
     - `terraform.languageServer.enable`: Enable language server features

   ![VS Code Terraform Settings](screenshots/vscode-terraform-settings.png)
   *Screenshot: VS Code settings showing Terraform configuration options*

3. **Recommended Settings** (Add to `settings.json`):
   ```json
   {
     "terraform.formatOnSave": true,
     "terraform.format.enable": true,
     "terraform.languageServer.enable": true,
     "[terraform]": {
       "editor.defaultFormatter": "hashicorp.terraform",
       "editor.formatOnSave": true
     },
     "[terraformvars]": {
       "editor.defaultFormatter": "hashicorp.terraform"
     }
   }
   ```

### Troubleshooting VS Code Extensions

**Issue: Extension not working**
- Reload VS Code: Press `Ctrl+Shift+P` → Type "Reload Window"
- Check if Terraform is in your PATH: Open terminal in VS Code and run `terraform version`
- Verify extension is enabled: Check Extensions view

**Issue: No syntax highlighting**
- Make sure file has `.tf` extension
- Check that HashiCorp Terraform extension is installed and enabled
- Try reloading VS Code

**Issue: Auto-completion not working**
- Ensure Terraform language server is enabled in settings
- Check that Terraform binary is accessible from VS Code terminal
- Restart the Terraform language server: `Ctrl+Shift+P` → "Terraform: Restart Language Server"

### Alternative: Install via Command Line

If you prefer command line, you can install extensions using VS Code's command-line interface:

```bash
# Install HashiCorp Terraform extension
code --install-extension hashicorp.terraform

# Install Azure Terraform extension (optional)
code --install-extension ms-azuretools.azure-terraform
```

**Note:** Replace `code` with `code-insiders` if you're using VS Code Insiders edition.

### What's Next?

After installing VS Code extensions, you're ready to:
- Write Terraform configurations with better tooling support
- Catch errors before running Terraform commands
- Format your code automatically
- Get helpful documentation and examples

**Pro Tip:** Keep VS Code open while following this guide—you can create and edit Terraform files as you go!

---

## Understanding Authentication Methods

Terraform can authenticate with Azure in several ways:

### 1. **Service Principal (Recommended for Production)**
- Non-human identity (like a service account)
- Uses client ID, client secret, tenant ID, and subscription ID
- Best for CI/CD pipelines and automated deployments
- **This guide covers this method**

### 2. **Azure CLI Authentication**
- Uses your personal Azure account credentials
- Simpler for local development
- Not recommended for production/automation

### 3. **Managed Identity**
- Used when Terraform runs on Azure resources (VMs, App Services)
- No credentials needed
- Most secure for Azure-hosted workloads

**Why Service Principal?**
- Secure: Credentials are separate from your personal account
- Scalable: Can be used in automation and CI/CD
- Auditable: Actions are tied to the service principal, not individual users
- Flexible: Can be scoped to specific subscriptions or resource groups

---

## Step 1: Install Required Tools

You need several tools: Azure CLI, Terraform, and GitHub CLI (gh).

### 1.1 Install Azure CLI

Azure CLI is Microsoft's command-line tool for managing Azure resources.

#### For Ubuntu/Debian:

```bash
# Update package index
sudo apt-get update

# Install required packages
sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg

# Download and install Microsoft signing key
curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

# Add Azure CLI repository
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list

# Update package index again
sudo apt-get update

# Install Azure CLI
sudo apt-get install -y azure-cli
```

**Alternative One-Line Install (Ubuntu/Debian):**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

#### For RHEL/CentOS/Fedora:

```bash
# Import Microsoft repository key

# Add Azure CLI repository
sudo sh -c 'echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'

# Install Azure CLI
sudo yum install -y azure-cli
```

**Alternative One-Line Install (RHEL/CentOS):**
```bash
curl -sL https://aka.ms/InstallAzureCLIRPM | sudo bash
sudo yum install -y azure-cli
```

#### For openSUSE/SLES:

```bash
sudo zypper addrepo https://packages.microsoft.com/config/sles/15/prod.repo
sudo zypper install --from azure-cli azure-cli
```

**Explanation:**
- We're adding Microsoft's official package repository
- This ensures you get the latest stable version
- The repository is signed with Microsoft's GPG key for security

### 1.2 Install Terraform

Terraform is HashiCorp's Infrastructure as Code tool.

#### Method 1: Using Package Manager (Simplest)

**For Ubuntu/Debian:**
```bash
# Install required packages
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# Add HashiCorp repository
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Update and install Terraform
sudo apt-get update && sudo apt-get install terraform
```

**For RHEL/CentOS/Fedora:**
```bash
# Install required packages
sudo yum install -y yum-utils

# Add HashiCorp repository
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

# Install Terraform
sudo yum install -y terraform
```

#### Method 2: Manual Installation (Any Linux Distribution)

```bash
# Set version (check latest at https://www.terraform.io/downloads)
TERRAFORM_VERSION="1.6.0"

# Download Terraform
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install unzip if not present
sudo apt-get install -y unzip  # Ubuntu/Debian
# OR
sudo yum install -y unzip      # RHEL/CentOS

# Extract Terraform
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Move to system PATH
sudo mv terraform /usr/local/bin/

# Clean up
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
```

**Explanation:**
- Method 1 uses package managers for easier updates
- Method 2 gives you more control over the version
- Terraform binary is placed in `/usr/local/bin` which is typically in your PATH

### 1.3 Install Additional Tools (Optional but Recommended)

**jq** - JSON processor (useful for parsing Service Principal output):

```bash
# Ubuntu/Debian
sudo apt-get install -y jq

# RHEL/CentOS/Fedora
sudo yum install -y jq
```

**Explanation:**
- `jq` makes it easier to extract values from JSON files
- We'll use it to parse the Service Principal output automatically

### 1.4 Install GitHub CLI (gh)

GitHub CLI (`gh`) is GitHub's official command-line tool for interacting with GitHub repositories, managing pull requests, issues, and more. It's useful for managing Terraform modules and CI/CD workflows.

#### For Ubuntu/Debian:

```bash
# Update package index
sudo apt-get update

# Install required packages
sudo apt-get install -y curl

# Download and add GitHub CLI signing key
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

# Add GitHub CLI repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
    sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Update package index
sudo apt-get update

# Install GitHub CLI
sudo apt-get install -y gh
```

**Alternative One-Line Install (Ubuntu/Debian):**
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && sudo apt update && sudo apt install gh -y
```

#### For RHEL/CentOS/Fedora:

```bash
# Import GitHub CLI repository key
sudo rpm --import https://cli.github.com/packages/githubcli-archive-keyring.gpg

# Add GitHub CLI repository
sudo sh -c 'echo -e "[github-cli]
name=GitHub CLI
baseurl=https://cli.github.com/packages/rpm
enabled=1
gpgcheck=1
gpgkey=https://cli.github.com/packages/githubcli-archive-keyring.gpg" > /etc/yum.repos.d/github-cli.repo'

# Install GitHub CLI
sudo yum install -y gh
```

**For Fedora:**
```bash
sudo dnf install -y gh
```

#### For openSUSE/SLES:

```bash
# Add GitHub CLI repository
sudo zypper addrepo https://cli.github.com/packages/rpm/gh-cli.repo

# Refresh repositories
sudo zypper refresh

# Install GitHub CLI
sudo zypper install gh
```

#### Manual Installation (Any Linux Distribution):

If your distribution doesn't have a package available, you can download the binary directly:

```bash
# Set version (check latest at https://github.com/cli/cli/releases)
GH_VERSION="2.40.0"

# Download GitHub CLI
wget https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz

# Extract
tar -xzf gh_${GH_VERSION}_linux_amd64.tar.gz

# Move to system PATH
sudo mv gh_${GH_VERSION}_linux_amd64/bin/gh /usr/local/bin/

# Clean up
rm -rf gh_${GH_VERSION}_linux_amd64 gh_${GH_VERSION}_linux_amd64.tar.gz
```

**Explanation:**
- GitHub CLI provides command-line access to GitHub features
- Useful for managing repositories, pull requests, and GitHub Actions
- Official package repositories ensure you get the latest stable version
- The manual installation method works on any Linux distribution

**What GitHub CLI Can Do:**
- Authenticate with GitHub (browser or token)
- Clone repositories
- Create and manage pull requests
- Manage issues and projects
- Work with GitHub Actions
- Manage repository settings
- Much more!

**Note:** After installation, you'll need to authenticate with GitHub. See the GitHub authentication guide for details.

### 1.5 Configure Terminal (Recommended)

Some terminals (especially SSH sessions) have bracketed paste mode enabled, which can cause issues when pasting commands. Disable it for a better experience:

```bash
# Disable bracketed paste mode
echo "set enable-bracketed-paste off" >> ~/.inputrc

# Apply the configuration to current session
bind -f ~/.inputrc
```

**Explanation:**
- Bracketed paste mode can cause commands to paste incorrectly in some terminals
- This configuration disables it for all future terminal sessions
- The `bind -f ~/.inputrc` command applies it immediately to your current session
- This is especially helpful when working in SSH sessions or certain terminal emulators

**What This Does:**
- Adds a configuration line to your `~/.inputrc` file (readline configuration)
- Prevents terminal from interpreting paste operations as typed input
- Makes copying and pasting commands more reliable

**Note:** This change takes effect immediately and persists for all future terminal sessions.

---

## Step 2: Verify Installation

Before proceeding, verify that all tools are installed correctly:

```bash
# Check Azure CLI version
az version

# Check Terraform version
terraform version

# Check jq (if installed)
sudo apt install jq
jq --version

# Check GitHub CLI version
sudo apt  install gh
gh --version
```

**Expected Output:**

```bash
$ az version
{
  "azure-cli": "2.55.0",
  "azure-cli-core": "2.55.0",
  ...
}

$ terraform version
Terraform v1.6.0
on linux_amd64

$ gh --version
gh version 2.40.0 (2024-01-15)
https://github.com/cli/cli/releases/tag/v2.40.0
```

**Explanation:**
- Version checks confirm the tools are installed and accessible
- If you see "command not found", the installation failed or PATH isn't configured

**Troubleshooting:**
- If commands aren't found, try logging out and back in (refreshes PATH)
- Or manually add to PATH: `export PATH=$PATH:/usr/local/bin`
- For GitHub CLI, verify installation: `which gh`
- If `gh` command not found, check if `/usr/local/bin` is in your PATH

---

## Step 3: Log in to Azure CLI

You must authenticate with Azure CLI before creating a Service Principal.

### 3.1 Interactive Login (Recommended for First Time)

```bash
az login --use-device-code
```

**What happens:**
1. Azure CLI opens your default web browser
2. You're prompted to sign in with your Azure account
3. After successful login, the browser shows "You have logged in"
4. The terminal receives authentication tokens

**Expected Output:**
```json
[
  {
    "cloudName": "AzureCloud",
    "id": "12345678-1234-1234-1234-123456789012",
    "isDefault": true,
    "name": "Visual Studio Enterprise Subscription",
    "state": "Enabled",
    "tenantId": "87654321-4321-4321-4321-210987654321",
    "user": {
      "name": "your.email@example.com",
      "type": "user"
    }
  }
]
```

### 3.2 Device Code Login (For Headless Systems or SSH Sessions)

If you're working on a remote Linux server without a GUI:

```bash
az login --use-device-code
```

**What happens:**
1. Azure CLI displays a code and URL
2. You visit the URL on any device (phone, another computer)
3. Enter the code when prompted
4. Sign in with your Azure account
5. Terminal receives authentication tokens

**Expected Output:**
```
To sign in, use a web browser to open the page https://microsoft.com/devicelogin
and enter the code ABC123XYZ to authenticate.
```

**Explanation:**
- Interactive login is easier if you have a GUI
- Device code login works anywhere, even on headless servers
- Both methods authenticate your Azure CLI session
- Authentication tokens are stored locally (usually in `~/.azure/`)

**Security Note:**
- Tokens expire after a period of inactivity
- You may need to re-authenticate periodically
- Tokens are stored securely on your local machine

---

## Step 4: Set Active Subscription

If you have multiple Azure subscriptions, you need to specify which one to use.

### What is a Subscription and Subscription ID?

**In Plain English:**

Think of an **Azure Subscription** like a separate "account" or "workspace" within your Azure account. It's like having multiple bank accounts—they're all yours, but each one is separate for billing, resources, and management.

**Subscription ID** is like the account number for that subscription. It's a unique identifier (a GUID—a long string of numbers and letters) that Azure uses to know exactly which subscription you're talking about.

**Real-World Analogy:**
- **Azure Account** = Your company (e.g., "Acme Corporation")
- **Subscription** = A department's budget account (e.g., "Engineering Department Budget")
- **Subscription ID** = The account number for that budget (e.g., "12345678-1234-1234-1234-123456789012")
- **Resources** = Things you buy with that budget (VMs, storage, databases)

**Why You Need It:**

1. **Billing**: Each subscription has its own bill. You can track costs separately for different projects or departments.

2. **Resource Organization**: All your Azure resources (VMs, storage accounts, databases) belong to a specific subscription. You can't create resources without a subscription.

3. **Access Control**: You can give different people access to different subscriptions. For example, the development team only has access to the "dev" subscription.

4. **Limits**: Azure has limits per subscription (like how many VMs you can create). Having multiple subscriptions lets you work around these limits.

5. **Terraform**: When Terraform connects to Azure, it needs to know which subscription to manage. The Subscription ID tells Terraform exactly which subscription to work with.

**Subscription ID Format:**
- It's a GUID (Globally Unique Identifier)
- Format: `12345678-1234-1234-1234-123456789012`
- Always 36 characters (32 hex digits + 4 hyphens)
- Never changes—it's permanent for that subscription

**Common Scenarios:**
- **One Subscription**: If you only have one subscription, you still need to know its ID for Terraform
- **Multiple Subscriptions**: You might have:
  - `dev-subscription` for development work
  - `prod-subscription` for production
  - `test-subscription` for testing
  - Each has its own unique Subscription ID

**Where to Find Your Subscription ID:**
- Azure Portal: Go to Subscriptions → Your Subscription → Overview → Subscription ID
- Azure CLI: `az account show --query id -o tsv`
- It's shown in the output when you list subscriptions

### 4.1 List Available Subscriptions

```bash
az account list --output table
```

**Expected Output:**
```
Name                          SubscriptionId                        State    IsDefault
----------------------------  ------------------------------------  --------  -----------
Visual Studio Enterprise     12345678-1234-1234-1234-123456789012  Enabled   True
Pay-As-You-Go                87654321-4321-4321-4321-210987654321  Enabled   False
```

### 4.2 Set Active Subscription

**By Subscription Name:**
```bash
az account set --subscription "Visual Studio Enterprise"
```

**By Subscription ID:**
```bash
az account set --subscription "12345678-1234-1234-1234-123456789012"
```

### 4.3 Verify Active Subscription

```bash
az account show
```

**Expected Output:**
```json
{
  "environmentName": "AzureCloud",
  "id": "12345678-1234-1234-1234-123456789012",
  "isDefault": true,
  "name": "Visual Studio Enterprise Subscription",
  "state": "Enabled",
  "tenantId": "87654321-4321-4321-4321-210987654321",
  "user": {
    "name": "your.email@example.com",
    "type": "user"
  }
}
```

**Explanation:**
- Azure accounts can have multiple subscriptions
- Each subscription is a separate billing and resource container
- You must select which subscription Terraform will manage
- The `--subscription` flag accepts either name or ID

**Why it matters:**
- Service Principals are created at the subscription level
- Terraform will only manage resources in the active subscription
- Billing is tracked per subscription

---

## Step 5: Create Service Principal

A Service Principal is a non-human identity that Terraform uses to authenticate and manage Azure resources.

### 5.1 Create Service Principal with Contributor Role

```bash
az ad sp create-for-rbac \
  --role="Contributor" \
  --scopes="/subscriptions/$(az account show --query id -o tsv)" \
  --name "http://terraform-service-principal" \
  > ./sp_output.json
```

**Breaking Down the Command:**

- `az ad sp create-for-rbac`: Creates a Service Principal using "Role-Based Access Control"
- `--role="Contributor"`: Assigns the Contributor role (can manage all resources except access)
- `--scopes="/subscriptions/...`: Limits scope to current subscription
  - `$(az account show --query id -o tsv)`: Gets current subscription ID
- `--name "http://terraform-service-principal"`: Name/identifier for the Service Principal
- `> ./sp_output.json`: Saves output to a JSON file

**Expected Output (saved to sp_output.json):**
```json
{
  "appId": "abcd1234-5678-90ab-cdef-1234567890ab",
  "displayName": "terraform-service-principal",
  "password": "xyz789~SecretPassword123~ABC",
  "tenant": "87654321-4321-4321-4321-210987654321"
}
```

### 5.2 View the Output File

```bash
cat sp_output.json
```

**Or with jq for formatted output:**
```bash
jq '.' sp_output.json
```

**🚨 CRITICAL SECURITY WARNING 🚨**

**SAVE THIS INFORMATION SECURELY!**
- The `password` field is shown **ONLY ONCE** during creation
- If you lose it, you must create a new Service Principal
- Store `sp_output.json` securely (encrypted, access-controlled)
- **NEVER commit this file to version control!**

**Explanation:**
- Service Principal = Application identity (like a service account)
- Contributor role = Can create/modify/delete resources (but not manage access)
- Scope = Where the Service Principal has permissions (subscription level)
- The password is a client secret used for authentication

**Alternative Roles:**
- `Owner`: Full access including access management
- `Reader`: Read-only access
- `Contributor`: Can manage resources but not access (recommended)

---

## Step 6: Understand Service Principal Output

Let's break down what each field means:

| JSON Key | Environment Variable | Description | Example |
|----------|---------------------|-------------|---------|
| `appId` | `ARM_CLIENT_ID` | Unique identifier for the Service Principal | `abcd1234-5678-90ab-cdef-1234567890ab` |
| `password` | `ARM_CLIENT_SECRET` | Secret key for authentication (shown once!) | `xyz789~SecretPassword123~ABC` |
| `tenant` | `ARM_TENANT_ID` | Your Azure AD tenant ID | `87654321-4321-4321-4321-210987654321` |
| `displayName` | N/A | Human-readable name | `terraform-service-principal` |

**Additional Information Needed:**

You also need your **Subscription ID**:

```bash
az account show --query id -o tsv
```

This will be set as `ARM_SUBSCRIPTION_ID`.

**Explanation:**
- **Client ID (appId)**: Like a username - identifies the Service Principal
- **Client Secret (password)**: Like a password - authenticates the Service Principal
- **Tenant ID**: Identifies your Azure Active Directory organization
- **Subscription ID**: Identifies which Azure subscription to manage

**Subscription ID Explained (Plain English):**
The Subscription ID is like the "account number" for your Azure subscription. Just like a bank account number identifies which account to deposit money into, the Subscription ID tells Terraform (and Azure) exactly which subscription to create resources in and manage.

**Why Terraform Needs It:**
- When Terraform creates a VM or storage account, Azure needs to know: "Which subscription should this resource belong to?"
- The Subscription ID answers that question
- Without it, Terraform wouldn't know where to put your resources
- It's like telling a delivery driver which house address to deliver to—without the address, they can't deliver

**Important Notes:**
- The Subscription ID is **not a secret**—it's just an identifier
- It's safe to include in code and configuration files (unlike passwords)
- However, it can reveal information about your Azure setup, so don't share it publicly
- Each subscription has exactly one Subscription ID that never changes

**How Authentication Works:**
1. Terraform sends Client ID + Client Secret + Tenant ID to Azure
2. Azure validates credentials and returns an access token
3. Terraform uses the token to make API calls to manage resources
4. Subscription ID tells Azure which subscription to work with

---

## Step 7: Configure Environment Variables

Terraform's Azure provider automatically reads these environment variables for authentication.

### 7.1 Extract Values from JSON File

**Manual Method (if jq is not installed):**

```bash
# Read the JSON file and extract values manually
ARM_CLIENT_ID=$(cat sp_output.json | grep -o '"appId": "[^"]*' | cut -d'"' -f4)
ARM_CLIENT_SECRET=$(cat sp_output.json | grep -o '"password": "[^"]*' | cut -d'"' -f4)
ARM_TENANT_ID=$(cat sp_output.json | grep -o '"tenant": "[^"]*' | cut -d'"' -f4)
ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
```

**Using jq (Recommended - More Reliable):**

```bash
export ARM_CLIENT_ID=$(jq -r '.appId' sp_output.json)
export ARM_CLIENT_SECRET=$(jq -r '.password' sp_output.json)
export ARM_TENANT_ID=$(jq -r '.tenant' sp_output.json)
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
```

**Manual Entry (If you prefer to type):**

```bash
export ARM_CLIENT_ID="abcd1234-5678-90ab-cdef-1234567890ab"
export ARM_CLIENT_SECRET="xyz789~SecretPassword123~ABC"
export ARM_TENANT_ID="87654321-4321-4321-4321-210987654321"
export ARM_SUBSCRIPTION_ID="12345678-1234-1234-1234-123456789012"
```

**Explanation:**
- `export` makes variables available to child processes (like Terraform)
- `jq -r '.appId'` extracts the `appId` field from JSON (raw string, no quotes)
- Environment variables are only available in the current shell session
- Terraform automatically detects these variables (no configuration needed)

### 7.2 Verify Environment Variables Are Set

```bash
# Check each variable
echo "ARM_CLIENT_ID: $ARM_CLIENT_ID"
echo "ARM_CLIENT_SECRET: $ARM_CLIENT_SECRET"
echo "ARM_TENANT_ID: $ARM_TENANT_ID"
echo "ARM_SUBSCRIPTION_ID: $ARM_SUBSCRIPTION_ID"
```

**Expected Output:**
```
ARM_CLIENT_ID: abcd1234-5678-90ab-cdef-1234567890ab
ARM_CLIENT_SECRET: xyz789~SecretPassword123~ABC
ARM_TENANT_ID: 87654321-4321-4321-4321-210987654321
ARM_SUBSCRIPTION_ID: 12345678-1234-1234-1234-123456789012
```

**Quick Check (One Line):**
```bash
echo $ARM_CLIENT_ID
```

If you see a value (not empty), the variable is set correctly.

**Important Notes:**
- Variables are **only available in the current terminal session**
- If you open a new terminal, you must set them again
- See Step 9 for making them persistent

---

## Step 8: Verify Authentication

Test that Terraform can authenticate with Azure.

### 8.1 Create a Test Terraform Configuration

Create a simple `test_auth.tf` file:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Test data source - doesn't create anything, just reads
data "azurerm_subscription" "current" {}

output "subscription_id" {
  value = data.azurerm_subscription.current.id
}

output "subscription_display_name" {
  value = data.azurerm_subscription.current.display_name
}
```

### 8.2 Initialize and Test

```bash
# Initialize Terraform (downloads Azure provider)
terraform init

# Validate configuration
terraform validate

# Plan (tests authentication)
terraform plan
```

**Expected Output (Success):**
```
Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "~> 3.0"...
- Installing hashicorp/azurerm v3.xx.x...
...

Terraform has been successfully initialized!

No changes. Infrastructure is up-to-date.
```

**If Authentication Fails:**
```
Error: building AzureRM Client: obtain subscription() from Azure CLI: 
Error parsing json result from the Azure CLI: 
Please ensure you have logged in via `az login`.
```

**Explanation:**
- `terraform init` downloads the Azure provider plugin
- `terraform plan` attempts to connect to Azure (tests authentication)
- If successful, you're ready to use Terraform!
- If it fails, check your environment variables

### 8.3 Clean Up Test File

```bash
rm test_auth.tf terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl
rm -rf .terraform/
```

---

## Step 9: Persist Environment Variables

Environment variables set with `export` are lost when you close the terminal. Here are ways to make them persistent.

### 9.1 Method 1: Add to Shell Profile (Recommended for Development)

**For Bash:**
```bash
# Edit your .bashrc file
nano ~/.bashrc

# Add these lines at the end:
export ARM_CLIENT_ID="your-client-id-here"
export ARM_CLIENT_SECRET="your-client-secret-here"
export ARM_TENANT_ID="your-tenant-id-here"
export ARM_SUBSCRIPTION_ID="your-subscription-id-here"

# Save and exit (Ctrl+X, then Y, then Enter)

# Reload your profile
source ~/.bashrc
```

**For Zsh:**
```bash
# Edit your .zshrc file
nano ~/.zshrc

# Add the same export lines as above
# Then reload:
source ~/.zshrc
```

**Security Consideration:**
- Credentials are stored in plain text in your home directory
- Only readable by you (file permissions: 600)
- Good for local development, not for shared systems

### 9.2 Method 2: Use a .env File (More Secure)

Create a `.env` file in your project directory:

```bash
# Create .env file
cat > .env << EOF
ARM_CLIENT_ID=your-client-id-here
ARM_CLIENT_SECRET=your-client-secret-here
ARM_TENANT_ID=your-tenant-id-here
ARM_SUBSCRIPTION_ID=your-subscription-id-here
EOF

# Set restrictive permissions (only you can read)
chmod 600 .env
```

**Load the .env file before running Terraform:**
```bash
# Source the .env file
set -a  # Automatically export all variables
source .env
set +a  # Turn off automatic export

# Now run Terraform
terraform plan
```

**Or create a wrapper script:**
```bash
#!/bin/bash
# terraform-wrapper.sh
set -a
source .env
set +a
terraform "$@"
```

**Make it executable:**
```bash
chmod +x terraform-wrapper.sh
./terraform-wrapper.sh plan
```

**Important:**
- Add `.env` to `.gitignore` to prevent committing secrets!
- Never commit `.env` files to version control

### 9.3 Method 3: Use a Secrets Manager (Production)

For production environments, use:
- **Azure Key Vault**: Store secrets in Azure
- **HashiCorp Vault**: Enterprise secrets management
- **AWS Secrets Manager**: If using AWS
- **Environment variables in CI/CD**: Set in pipeline configuration

**Example with Azure Key Vault:**
```bash
# Install Azure Key Vault CLI extension
az extension add --name keyvault-preview

# Store secrets in Key Vault
az keyvault secret set --vault-name my-keyvault --name ARM-CLIENT-ID --value "your-id"
az keyvault secret set --vault-name my-keyvault --name ARM-CLIENT-SECRET --value "your-secret"

# Retrieve and set environment variables
export ARM_CLIENT_ID=$(az keyvault secret show --vault-name my-keyvault --name ARM-CLIENT-ID --query value -o tsv)
export ARM_CLIENT_SECRET=$(az keyvault secret show --vault-name my-keyvault --name ARM-CLIENT-SECRET --query value -o tsv)
```

---

## Step 10: Using Helper Scripts

To simplify the process, you can create helper scripts.

### 10.1 Create set_vars.sh Script

Create a script that automatically reads `sp_output.json` and sets environment variables:

```bash
#!/bin/bash
# set_vars.sh - Sets Terraform Azure authentication environment variables

# Check if sp_output.json exists
if [ ! -f "sp_output.json" ]; then
    echo "Error: 'sp_output.json' not found."
    echo "Please ensure you have created a Service Principal and saved the output to sp_output.json"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed."
    echo "Install it with: sudo apt-get install jq  (Ubuntu/Debian)"
    echo "                  sudo yum install jq      (RHEL/CentOS)"
    exit 1
fi

echo "Reading credentials from sp_output.json..."

# Extract values from JSON and set as environment variables
export ARM_CLIENT_ID=$(jq -r '.appId' sp_output.json)
export ARM_CLIENT_SECRET=$(jq -r '.password' sp_output.json)
export ARM_TENANT_ID=$(jq -r '.tenant' sp_output.json)

# Get subscription ID from Azure CLI
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Verify variables are set
if [ -z "$ARM_CLIENT_ID" ] || [ -z "$ARM_CLIENT_SECRET" ] || [ -z "$ARM_TENANT_ID" ] || [ -z "$ARM_SUBSCRIPTION_ID" ]; then
    echo "Error: Failed to set one or more environment variables"
    exit 1
fi

echo "✓ Environment variables set successfully:"
echo "  ARM_CLIENT_ID: ${ARM_CLIENT_ID:0:8}..." # Show only first 8 chars for security
echo "  ARM_TENANT_ID: $ARM_TENANT_ID"
echo "  ARM_SUBSCRIPTION_ID: $ARM_SUBSCRIPTION_ID"
echo ""
echo "Note: These variables are only available in the current shell session."
echo "To make them persistent, add them to your ~/.bashrc or use a .env file."
```

**Make it executable:**
```bash
chmod +x set_vars.sh
```

**Usage:**
```bash
# Source the script (not execute) to set variables in current shell
source ./set_vars.sh

# Or use the dot notation
. ./set_vars.sh
```

**Explanation:**
- Script checks for required files and tools
- Automatically extracts values from JSON
- Sets all four required environment variables
- Provides feedback on success/failure
- Uses `source` or `.` to run in current shell (so exports work)

### 10.2 Create verify_auth.sh Script

Create a script to verify authentication:

```bash
#!/bin/bash
# verify_auth.sh - Verifies Terraform Azure authentication

echo "Checking environment variables..."

# Check if variables are set
if [ -z "$ARM_CLIENT_ID" ]; then
    echo "✗ ARM_CLIENT_ID is not set"
    exit 1
fi

if [ -z "$ARM_CLIENT_SECRET" ]; then
    echo "✗ ARM_CLIENT_SECRET is not set"
    exit 1
fi

if [ -z "$ARM_TENANT_ID" ]; then
    echo "✗ ARM_TENANT_ID is not set"
    exit 1
fi

if [ -z "$ARM_SUBSCRIPTION_ID" ]; then
    echo "✗ ARM_SUBSCRIPTION_ID is not set"
    exit 1
fi

echo "✓ All environment variables are set"

# Test Azure CLI authentication
echo ""
echo "Testing Azure CLI authentication..."
az account show > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Azure CLI is authenticated"
    az account show --query "{Name:name, SubscriptionId:id}" -o table
else
    echo "✗ Azure CLI is not authenticated. Run 'az login'"
fi

# Test Terraform (if terraform is available)
if command -v terraform &> /dev/null; then
    echo ""
    echo "Testing Terraform authentication..."
    terraform version > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✓ Terraform is installed"
        echo "  Run 'terraform init' and 'terraform plan' to test Azure authentication"
    else
        echo "✗ Terraform is not installed or not in PATH"
    fi
else
    echo ""
    echo "ℹ Terraform is not installed"
fi
```

**Make it executable and run:**
```bash
chmod +x verify_auth.sh
./verify_auth.sh
```

---

## Troubleshooting

### Issue: "az: command not found"

**Solution:**
- Azure CLI is not installed or not in PATH
- Reinstall Azure CLI (see Step 1.1)
- Check PATH: `echo $PATH`
- Try full path: `/usr/bin/az --version`

### Issue: "terraform: command not found"

**Solution:**
- Terraform is not installed or not in PATH
- Reinstall Terraform (see Step 1.2)
- Verify installation: `which terraform`
- Add to PATH if needed: `export PATH=$PATH:/usr/local/bin`

### Issue: "Please run 'az login' to setup account"

**Solution:**
- You haven't logged in to Azure CLI
- Run: `az login` or `az login --use-device-code`
- Verify: `az account show`

### Issue: "Error: building AzureRM Client: obtain subscription()"

**Solution:**
- Environment variables are not set
- Check: `echo $ARM_CLIENT_ID`
- Set variables: `source ./set_vars.sh` or manually export
- Verify all four variables are set

### Issue: "Error: authorization failed"

**Solution:**
- Service Principal credentials are incorrect
- Check `sp_output.json` file exists and is valid
- Verify you copied the password correctly (it's shown only once)
- Recreate Service Principal if password is lost

### Issue: "Error: subscription not found"

**Solution:**
- Wrong subscription ID
- List subscriptions: `az account list --output table`
- Set correct subscription: `az account set --subscription "Name"`
- Update `ARM_SUBSCRIPTION_ID` environment variable

### Issue: "jq: command not found"

**Solution:**
- Install jq: `sudo apt-get install jq` (Ubuntu/Debian)
- Or use manual extraction method (see Step 7.1)

### Issue: "gh: command not found"

**Solution:**
- GitHub CLI is not installed or not in PATH
- Reinstall GitHub CLI (see Step 1.4)
- Verify installation: `which gh`
- Check PATH: `echo $PATH`
- Try full path: `/usr/local/bin/gh --version`

### Issue: "Permission denied" when running scripts

**Solution:**
- Make script executable: `chmod +x script_name.sh`
- Or run with bash: `bash script_name.sh`

### Issue: Environment variables not persisting

**Solution:**
- Variables set with `export` are session-only
- Add to `~/.bashrc` or `~/.zshrc` (see Step 9.1)
- Or use `.env` file method (see Step 9.2)
- Remember to `source` the file, not execute it

---

## Security Best Practices

### 1. **Protect Service Principal Credentials**
- ✅ Store `sp_output.json` securely (encrypted storage)
- ✅ Use file permissions: `chmod 600 sp_output.json`
- ✅ Never commit credentials to version control
- ✅ Add to `.gitignore`: `sp_output.json`, `.env`

### 2. **Use Least Privilege**
- ✅ Use `Contributor` role instead of `Owner` when possible
- ✅ Scope Service Principal to specific resource groups if needed
- ✅ Create separate Service Principals for different environments

### 3. **Rotate Credentials Regularly**
- ✅ Set reminders to rotate Service Principal passwords
- ✅ Use Azure Key Vault for credential management
- ✅ Monitor Service Principal usage in Azure AD

### 4. **Secure Environment Variables**
- ✅ Don't hardcode credentials in Terraform files
- ✅ Use environment variables or secret managers
- ✅ Restrict file permissions on `.env` files: `chmod 600 .env`
- ✅ Use CI/CD secret management for automation

### 5. **Monitor and Audit**
- ✅ Enable Azure AD audit logs
- ✅ Review Service Principal activity regularly
- ✅ Set up alerts for unusual activity

### 6. **Network Security**
- ✅ Use IP restrictions on Service Principals when possible
- ✅ Use Private Endpoints for Azure services
- ✅ Implement network security groups

---

## Quick Reference Commands

```bash
# Install Azure CLI (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Terraform (Ubuntu/Debian)
sudo apt-get update && sudo apt-get install -y terraform

# Install jq
sudo apt-get install -y jq

# Install GitHub CLI (Ubuntu/Debian)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && sudo apt update && sudo apt install gh -y

# Login to Azure
az login

# Set subscription
az account set --subscription "Subscription Name"

# Create Service Principal
az ad sp create-for-rbac --role="Contributor" \
  --scopes="/subscriptions/$(az account show --query id -o tsv)" \
  --name "http://terraform-service-principal" > sp_output.json

# Set environment variables (using jq)
export ARM_CLIENT_ID=$(jq -r '.appId' sp_output.json)
export ARM_CLIENT_SECRET=$(jq -r '.password' sp_output.json)
export ARM_TENANT_ID=$(jq -r '.tenant' sp_output.json)
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Verify variables
echo $ARM_CLIENT_ID

# Test Terraform
terraform init
terraform plan
```

---

## Summary

You've learned how to:
1. ✅ Install Azure CLI, Terraform, and GitHub CLI on Linux
2. ✅ Authenticate with Azure using Azure CLI
3. ✅ Create a Service Principal for Terraform
4. ✅ Configure environment variables for authentication
5. ✅ Verify authentication works
6. ✅ Persist credentials securely
7. ✅ Use helper scripts to automate the process

**Next Steps:**
- Create your first Azure resource with Terraform
- Set up remote state storage
- Learn about Terraform variables and outputs
- Explore Terraform modules

**Remember:**
- Keep your Service Principal credentials secure
- Never commit credentials to version control
- Use least privilege principles
- Rotate credentials regularly

---

## Additional Resources

- [Azure CLI Documentation](https://docs.microsoft.com/cli/azure/)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Service Principal Best Practices](https://docs.microsoft.com/azure/active-directory/develop/app-objects-and-service-principals)
- [Azure Authentication Methods](https://docs.microsoft.com/azure/developer/terraform/get-started-cloud-shell-bash)

