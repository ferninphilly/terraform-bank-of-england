## 🔐 Terraform Module 4: Azure Key Vault for Secure Secrets Management

This module teaches you how to use **Azure Key Vault** to store sensitive data (like database passwords or API keys) and how to securely retrieve those secrets into your Terraform configuration using a **Data Source**.

### Prerequisites

1.  **Remote State Configured:** Your project must be initialized with the Azure Storage Backend (Module 3).
2.  **Authentication:** Your Service Principal must be active and set in your environment variables.
3.  **Permissions:** The Service Principal used by Terraform must have the following permissions assigned:
    * **Management Plane:** `Contributor` role (to create the Key Vault and related resources).
    * **Data Plane:** `Key Vault Administrator` or `Key Vault Secrets Officer` (to read and write secrets within the vault).

---

### Step 1: Define Key Vault Resources

We need to create the Key Vault itself and a sample secret to prove the connection works.

**A. Update `variables.tf`**
Add the following variable to specify the name of the secret you will store:

```terraform
# variables.tf

variable "database_secret_name" {
  description = "The name of the secret to store the database password."
  type        = string
  default     = "database-password-prod"
}

B. Update main.tf Add the configuration for the Key Vault and the sample secret. We use a random password for the secret's value to ensure it's generated securely.

# main.tf - Append this block

# --- 1. Random Password Resource (To securely generate the secret value) ---
resource "random_password" "db_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# --- 2. Azure Key Vault Resource ---
resource "azurerm_key_vault" "key_vault" {
  name                     = "tfmodule4-vault-${azurerm_resource_group.rg_lesson.name}" 
  location                 = azurerm_resource_group.rg_lesson.location
  resource_group_name      = azurerm_resource_group.rg_lesson.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  soft_delete_retention_days = 7

  # Ensure the Key Vault is accessible by the Service Principal (SP) running Terraform
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get",  # Allows Terraform to retrieve secrets
      "Set",  # Allows Terraform to create/update secrets
      "Delete" 
    ]
  }
}

# --- 3. Key Vault Secret Resource (The secret itself) ---
resource "azurerm_key_vault_secret" "db_secret" {
  name         = var.database_secret_name
  value        = random_password.db_password.result # Store the random password securely
  key_vault_id = azurerm_key_vault.key_vault.id
}

C. Add Required Data Sources We need two new data sources: one to get the current Service Principal (SP) details, and one to get the tenant ID. Add this before your resource blocks in `main.tf.`

# main.tf - Add this block at the top

# Retrieves details about the current authenticated identity (your Service Principal)
data "azurerm_client_config" "current" {}

# Optional: Ensure the Key Vault provider is available
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    # Add the random provider for the password generation
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

### Step 2: Deploy the Key Vault and Secret

1. Initialize Terraform: Run init to download the new `random` provider.

`terraform init`

2. Review the plan

`terraform plan`

3. Apply

`terraform apply`

_The secret value is now stored securely in the Key Vault and is NOT visible in your state file._

### Step 3: Securely Retrieve and Use the Secret

To demonstrate how other resources (like a database VM) can securely access this secret without exposing it, we use a Data Source to read the secret back from the vault.

A. Update main.tf Add a new data source block to read the secret's value. Place this near the top of your main.tf.

```terraform
# main.tf - Add this Data Source

# Data Source to retrieve the secret value from the vault
data "azurerm_key_vault_secret" "db_secret_retrieved" {
  name         = azurerm_key_vault_secret.db_secret.name
  key_vault_id = azurerm_key_vault.key_vault.id
}
```

B. Update outputs.tf We will now output the retrieved secret value to prove we can read it. In production, you would use this value in another resource (e.g., value = data.azurerm_key_vault_secret.db_secret_retrieved.value) instead of outputting it.

# outputs.tf - Append this block

output "retrieved_secret_value" {
  description = "The secret value retrieved from Key Vault (DO NOT DO THIS IN PROD)."
  value       = data.azurerm_key_vault_secret.db_secret_retrieved.value
  sensitive   = true # Marks the output as sensitive
}

### Step 4: Final verification

terraform plan
terraform apply

You will see the secret value displayed in the final output (marked as sensitive).

2. Check Azure Portal: Navigate to the Key Vault resource in the Azure Portal, go to Secrets, and verify the randomly generated password is saved there.

### Step 5: Cleanup

`terraform destroy`

This is the cornerstone of how we want to save sensitive data