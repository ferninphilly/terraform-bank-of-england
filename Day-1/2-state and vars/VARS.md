## 🧩 Terraform Variables and Precedence: The Order of Operations

Variables are the input mechanism for Terraform configuration, allowing you to define parameters (like resource names or regions) without hardcoding values. Understanding **precedence**—the strict order in which Terraform looks for and accepts a value—is crucial for managing multiple environments safely. 

---

### Part 1: The Components of a Variable

A variable is declared in a `variables.tf` file using the `variable` block.

```terraform
# variables.tf

variable "resource_location" {
  description = "The Azure region for all resources."
  type        = string
  default     = "eastus"
  sensitive   = true 
}

| Component | Description | Why It's Important |
| :--- | :--- | :--- |
| `description` | Explains the variable's purpose. | Helps teammates understand what the variable is for. |
| `type` | Enforces the data type (string, number, bool, list, map, object). | Prevents runtime errors caused by mismatched data formats. |
| `default` | The fallback value. If no value is supplied through any other means, this value is used. | Ensures the configuration can run without manual input if all other sources are missing. |

Part 2: The Terraform Precedence Hierarchy
Terraform determines the final value of a variable by checking sources in a precise, ascending order. The highest source found (Source 6) will override all sources below it.

| Source Level | Description | Example Usage/File | Override Power |
| :--- | :--- | :--- | :--- |
| **6. CLI Arguments** | Values passed directly on the command line. | `terraform apply -var='region=westus'` | **Highest** |
| **5. Environment Variables** | Variables prefixed with `TF_VAR_` (e.g., used for secrets). | `export TF_VAR_admin_user=admin` | High |
| **4. Auto-Loaded `.tfvars` Files** | Values read from two specific files in the root directory. | `terraform.tfvars` or `*.auto.tfvars` | Medium |
| **3. Manually Specified `.tfvars` Files** | A file specified explicitly at runtime. | `terraform apply -var-file="dev.tfvars"` | Medium-Low |
| **2. Local Values (`locals`)** | Values derived from other variables or constants inside the configuration. | Defined in a `locals {}` block. | Low (Internal) |
| **1. Variable `default`** | The value defined inside the `variable {}` block itself. | `default = "eastus"` | **Lowest** |

Explaining Key Concepts
A. Environment Variables (TF_VAR_)
These are the standard way to pass values without checking them into version control, especially sensitive ones (e.g., API keys, database usernames).

Rule: The variable name in the shell must be prefixed with TF_VAR_.

Example: For variable "admin_user" {}, the shell command is export TF_VAR_admin_user="JohnSmith".

B. The .tfvars Files
These files are used to define inputs for different environments (e.g., prod.tfvars, dev.tfvars).

terraform.tfvars: This exact file name is always loaded automatically by Terraform if it exists in the root directory.

*.auto.tfvars: Any file ending in .auto.tfvars (e.g., global.auto.tfvars) is also loaded automatically.

Manual Override: You can specify any other .tfvars file manually using the -var-file flag:

```bash
terraform apply -var-file="environments/prod.tfvars"
```
C. Local Values (locals)
The locals block allows you to assign a name to an expression or a derived value, making your main.tf file cleaner. Locals are internal to the configuration and cannot be overridden by external inputs.

Purpose: Simplify complex expressions or define constants (e.g., standard tagging scheme).

Example:

```terraform
# locals.tf

locals {
  common_tags = {
    Owner       = "Team-DevOps"
    Environment = "dev"
  }

```

Summary: The Override Check
When Terraform encounters a resource that needs the value of a variable, it checks its input sources from CLI (highest) down to Default (lowest).

Example Scenario: If you set a value via an environment variable (TF_VAR_region=westus) and also define a value in a prod.tfvars file (region = "eastus"), the Environment Variable (westus) will win because it sits higher in the precedence hierarchy than the .tfvars file.

This strict hierarchy ensures that automated and explicit command-line inputs always take precedence over configuration files and defaults.

