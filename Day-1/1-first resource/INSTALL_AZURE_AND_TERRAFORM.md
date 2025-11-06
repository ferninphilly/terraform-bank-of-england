## 🚀 Terraform Authentication with Azure: A Comprehensive Guide

This guide walks you through the necessary tooling installation and the secure, step-by-step process of authenticating the Terraform Azure Provider using an Azure Service Principal via the Azure Command-Line Interface (Azure CLI).

---

### 🛠️ Setup: Install Tooling

You need two main tools: the Azure Command-Line Interface (Azure CLI) to interact with Azure, and Terraform to manage the infrastructure.

#### 🍎 macOS Installation (using Homebrew)

If you don't have [Homebrew](https://brew.sh/) installed, install it first using the command from the Homebrew website.

| Tool | Command |
| :--- | :--- |
| **Azure CLI** | `brew update && brew install azure-cli` |
| **Terraform** | `brew tap hashicorp/tap` <br> `brew install hashicorp/tap/terraform` |

After running the commands, verify the installation:
```bash
az version
terraform version