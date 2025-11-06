## 🚀 Terraform Authentication with Azure: A Comprehensive Guide

This guide walks you through the recommended and most secure way to authenticate the Terraform Azure Provider using an Azure Service Principal via the Azure Command-Line Interface (Azure CLI).

### Prerequisites

Ensure you have the following tools installed and an active Azure Subscription:

1.  **Azure CLI:** Used to create the Service Principal and log in to Azure.
2.  **Terraform:** The Infrastructure as Code tool.

---

### Step 1: Install and Log in with Azure CLI

You must log in to the Azure CLI to create the necessary credentials and interact with your subscription.

1.  **Open your terminal or command prompt.**
2.  **Run the Azure login command:**
    ```bash
    az login
    ```
3.  Follow the browser prompts to sign in.
4.  If you have multiple subscriptions, set the one you plan to use:
    ```bash
    az account set --subscription "Your Subscription Name or ID"
    ```

---

### Step 2: Create an Azure Service Principal (The Application Identity)

A Service Principal is a non-human identity (like a service account) that Terraform will use to manage resources within your subscription.

1.  **Run the following command** to create a Service Principal and assign it the `Contributor` role at the scope of your current subscription:

    ```bash
    az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$(az account show --query id -o tsv)" --name "http://terraform-service-principal" > ./sp_output.json
    ```

2.  **🚨 SAVE THE OUTPUT! 🚨** This command outputs a JSON object with the credentials Terraform needs. **Copy and save this information securely.**

    | Key | Terraform Variable | Description |
    | :--- | :--- | :--- |
    | `"appId"` | `ARM_CLIENT_ID` | The Service Principal's unique identifier |
    | `"password"` | `ARM_CLIENT_SECRET` | The secret key/password |
    | `"tenant"` | `ARM_TENANT_ID` | Your organization's tenant ID |

---

### Step 3: Configure Environment Variables

For security, we avoid hardcoding credentials. Instead, we use environment variables, which Terraform's Azure provider automatically detects and uses for authentication.

Using the values saved from **Step 2**, run the following commands in your current terminal session:

**Bash (Linux/macOS) or PowerShell Core:**

```bash
export ARM_CLIENT_ID="<Your_appId_from_Step_2>"
export ARM_CLIENT_SECRET="<Your_password_from_Step_2>"
export ARM_TENANT_ID="<Your_tenant_from_Step_2>"
export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
```

The process can be simplified by creating a couple of files that we can run that will automatically create the env vars based on the outputs.

If you haven't just run `chmod +x ./set_vars.sh` and then, to set the env vars, you can run `source set_vars.sh`.

Check that the env vars have been set (in bash) by putting in `echo $ARM_CLIENT_ID`.

If you get a return value then congratulations! You are ready to use terraform!!