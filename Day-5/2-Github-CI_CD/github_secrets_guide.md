# Guide: Managing GitHub Secrets and Environment Variables

This guide walks you through setting up GitHub Secrets and Environment Variables for your Terraform CI/CD pipelines. These are essential for securely storing sensitive data like Azure credentials.

## Table of Contents
1. [Understanding GitHub Secrets](#understanding-github-secrets)
2. [Understanding Environment Variables](#understanding-environment-variables)
3. [Step 1: Navigate to Repository Settings](#step-1-navigate-to-repository-settings)
4. [Step 2: Add Repository Secrets](#step-2-add-repository-secrets)
5. [Step 3: Create GitHub Environments](#step-3-create-github-environments)
6. [Step 4: Add Environment Secrets](#step-4-add-environment-secrets)
7. [Step 5: Add Environment Variables](#step-5-add-environment-variables)
8. [Step 6: Verify Secrets in Workflows](#step-6-verify-secrets-in-workflows)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

---

## GitHub Actions Pricing - Free Tier Available!

### Can You Use GitHub Actions for Free?

**Yes!** GitHub Actions has a generous free tier that's perfect for learning:

#### ✅ Public Repositories - Completely Free
- **Unlimited** GitHub Actions minutes
- **Unlimited** storage
- **Unlimited** workflows
- **No credit card required**
- **Perfect for students and open-source projects**

#### ✅ Private Repositories - Free Tier Available
- **2,000 minutes/month** free (Linux runners)
- **500 MB storage** free
- Usually enough for learning and small projects
- Additional minutes: $0.008 per minute if exceeded

#### Typical Usage for Learning
- Terraform validation: ~1-2 minutes per run
- Terraform plan: ~2-5 minutes per run
- Terraform apply: ~5-15 minutes per run

**Example monthly usage:**
- 50 PRs with validation + plan = ~150-350 minutes
- 10 deployments = ~50-150 minutes
- **Total: ~200-500 minutes/month** (well within free tier!)

### Recommendations

1. **For Learning**: Use **public repositories** - completely free, unlimited
2. **For Private Projects**: Free tier (2,000 min/month) is usually sufficient
3. **Monitor Usage**: Check Settings > Billing to track your usage

**Bottom Line**: You can use GitHub Actions completely free for learning! Public repos have unlimited free minutes.

---

## Understanding GitHub Secrets

### What are GitHub Secrets?

GitHub Secrets are encrypted variables that you can use in your GitHub Actions workflows. They are:
- ✅ **Encrypted at rest** - Stored securely by GitHub
- ✅ **Masked in logs** - Never displayed in workflow output
- ✅ **Scoped** - Can be repository-level or environment-level
- ✅ **Accessible** - Only available to workflows you explicitly grant access to

### When to Use Secrets

Use secrets for:
- Passwords and API keys
- Service principal credentials
- Database connection strings
- SSH private keys
- Any sensitive configuration data

**Never commit secrets to your repository!**

---

## Understanding Environment Variables

### What are Environment Variables?

Environment Variables are non-sensitive configuration values that can be:
- ✅ **Public** - Visible in workflow logs (use for non-sensitive data)
- ✅ **Reusable** - Same value across multiple workflows
- ✅ **Scoped** - Repository-level or environment-level

### When to Use Environment Variables

Use environment variables for:
- Non-sensitive configuration (e.g., region names, resource prefixes)
- Default values that might change
- Environment-specific settings (dev, staging, prod)

**Never use environment variables for secrets!**

---

## Step 1: Navigate to Repository Settings

### 1.1 Go to Your Repository

1. Navigate to your GitHub repository in a web browser
2. Click on the **Settings** tab (located at the top of the repository)

**Screenshot Location**: `screenshots/01-repository-settings-tab.png`
*[Screenshot should show: Repository page with Settings tab highlighted]*

### 1.2 Access Secrets and Variables

1. In the left sidebar, scroll down to **Secrets and variables**
2. Click on **Actions**

**Screenshot Location**: `screenshots/02-secrets-variables-menu.png`
*[Screenshot should show: Settings page with "Secrets and variables" > "Actions" highlighted in sidebar]*

You'll see two tabs:
- **Secrets** - For sensitive data
- **Variables** - For non-sensitive configuration

---

## Step 2: Add Repository Secrets

### 2.1 Open Secrets Tab

1. Click on the **Secrets** tab
2. You'll see a list of existing secrets (if any) or an empty list

**Screenshot Location**: `screenshots/03-secrets-tab-empty.png`
*[Screenshot should show: Secrets tab with "New repository secret" button visible]*

### 2.2 Create New Secret

1. Click the **New repository secret** button
2. You'll see a form with two fields:
   - **Name** - The name of your secret (how you'll reference it)
   - **Secret** - The actual secret value

**Screenshot Location**: `screenshots/04-new-secret-form.png`
*[Screenshot should show: Form with Name and Secret fields]*

### 2.3 Add Azure Credentials Secret

For Terraform with Azure, you'll need to add `AZURE_CREDENTIALS`:

**Name**: `AZURE_CREDENTIALS`

**Secret**: Paste the JSON output from your service principal creation:
```json
{
  "clientId": "12345678-1234-1234-1234-123456789012",
  "clientSecret": "your-client-secret-here",
  "subscriptionId": "87654321-4321-4321-4321-210987654321",
  "tenantId": "11111111-2222-3333-4444-555555555555"
}
```

**Steps:**
1. Enter `AZURE_CREDENTIALS` in the Name field
2. Paste the entire JSON object in the Secret field
3. Click **Add secret**

**Screenshot Location**: `screenshots/05-azure-credentials-secret.png`
*[Screenshot should show: Form filled with AZURE_CREDENTIALS name and JSON in secret field]*

**Important**: The secret value is masked as you type (shown as dots or asterisks).

### 2.4 Add Individual ARM Secrets (Alternative Method)

Instead of `AZURE_CREDENTIALS`, you can add individual secrets:

**Secret 1:**
- **Name**: `ARM_CLIENT_ID`
- **Secret**: Your service principal client ID (from `clientId` in JSON)

**Secret 2:**
- **Name**: `ARM_CLIENT_SECRET`
- **Secret**: Your service principal client secret (from `clientSecret` in JSON)

**Secret 3:**
- **Name**: `ARM_SUBSCRIPTION_ID`
- **Secret**: Your Azure subscription ID (from `subscriptionId` in JSON)

**Secret 4:**
- **Name**: `ARM_TENANT_ID`
- **Secret**: Your Azure tenant ID (from `tenantId` in JSON)

**Screenshot Location**: `screenshots/06-individual-arm-secrets.png`
*[Screenshot should show: List of secrets with ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_ID, ARM_TENANT_ID]*

### 2.5 Verify Secrets Created

After adding secrets, you'll see them listed:
- Secret names are visible
- Secret values are **never** shown (only "••••••••" or similar)
- You can update or delete secrets

**Screenshot Location**: `screenshots/07-secrets-list.png`
*[Screenshot should show: List of created secrets with masked values]*

---

## Step 3: Create GitHub Environments

Environments allow you to:
- Organize secrets by environment (dev, staging, production)
- Require approvals for production deployments
- Set deployment branches
- Use different secrets per environment

### 3.1 Navigate to Environments

1. Go to repository **Settings**
2. In the left sidebar, click **Environments** (under "Secrets and variables")

**Screenshot Location**: `screenshots/08-environments-menu.png`
*[Screenshot should show: Settings page with Environments option highlighted]*

### 3.2 Create New Environment

1. Click **New environment** button
2. Enter environment name (e.g., `dev`, `staging`, `production`)
3. Click **Configure environment**

**Screenshot Location**: `screenshots/09-new-environment.png`
*[Screenshot should show: New environment dialog with name field]*

### 3.3 Configure Environment

You'll see several configuration options:

**Environment name**: Already set (e.g., `production`)

**Deployment branches**:
- **All branches** - Deploy from any branch
- **Selected branches** - Only deploy from specific branches (recommended for production)
- **Protected branches only** - Only deploy from protected branches

**Environment protection rules** (for production):
- **Required reviewers** - Require approval before deployment
- **Wait timer** - Delay deployment by X minutes
- **Deployment branches** - Restrict which branches can deploy

**Screenshot Location**: `screenshots/10-environment-config.png`
*[Screenshot should show: Environment configuration page with deployment branches and protection rules]*

### 3.4 Add Required Reviewers (Production)

For production environment:
1. Check **Required reviewers**
2. Click **Add reviewer**
3. Select team members or users who can approve deployments
4. Click **Save protection rules**

**Screenshot Location**: `screenshots/11-required-reviewers.png`
*[Screenshot should show: Required reviewers section with users added]*

### 3.5 Create Multiple Environments

Repeat the process to create:
- `dev` - Development environment (no protection rules)
- `staging` - Staging environment (optional protection)
- `production` - Production environment (required reviewers)

**Screenshot Location**: `screenshots/12-multiple-environments.png`
*[Screenshot should show: List of environments: dev, staging, production]*

---

## Step 4: Add Environment Secrets

Environment secrets are scoped to a specific environment and override repository secrets.

### 4.1 Access Environment Secrets

1. Go to **Settings** > **Environments**
2. Click on an environment (e.g., `production`)
3. Scroll to **Environment secrets** section

**Screenshot Location**: `screenshots/13-environment-secrets-section.png`
*[Screenshot should show: Environment page with Environment secrets section visible]*

### 4.2 Add Environment Secret

1. Click **Add secret** button
2. Enter secret name (e.g., `ARM_SUBSCRIPTION_ID`)
3. Enter secret value
4. Click **Add secret**

**Screenshot Location**: `screenshots/14-add-environment-secret.png`
*[Screenshot should show: Add secret form for environment]*

### 4.3 Example: Different Subscriptions per Environment

You might want different Azure subscriptions for each environment:

**Dev Environment:**
- `ARM_SUBSCRIPTION_ID` = `dev-subscription-id`

**Staging Environment:**
- `ARM_SUBSCRIPTION_ID` = `staging-subscription-id`

**Production Environment:**
- `ARM_SUBSCRIPTION_ID` = `prod-subscription-id`

**Screenshot Location**: `screenshots/15-environment-specific-secrets.png`
*[Screenshot should show: Production environment with environment-specific secrets listed]*

---

## Step 5: Add Environment Variables

Environment variables are for non-sensitive configuration values.

### 5.1 Add Repository Variables

1. Go to **Settings** > **Secrets and variables** > **Actions**
2. Click on **Variables** tab
3. Click **New repository variable**

**Screenshot Location**: `screenshots/16-variables-tab.png`
*[Screenshot should show: Variables tab with New repository variable button]*

### 5.2 Create Variable

1. Enter variable name (e.g., `TF_VAR_location`)
2. Enter variable value (e.g., `eastus`)
3. Click **Add variable**

**Screenshot Location**: `screenshots/17-new-variable-form.png`
*[Screenshot should show: Form with variable name and value]*

### 5.3 Add Environment Variables

1. Go to **Settings** > **Environments**
2. Click on an environment
3. Scroll to **Environment variables** section
4. Click **Add variable**

**Screenshot Location**: `screenshots/18-environment-variables.png`
*[Screenshot should show: Environment variables section]*

### 5.4 Example Variables

**Repository Variables** (shared across all environments):
- `TF_VAR_default_location` = `eastus`
- `TF_VAR_default_tags` = `{"Environment":"shared"}`

**Environment Variables** (environment-specific):
- **Dev**: `TF_VAR_environment` = `dev`
- **Staging**: `TF_VAR_environment` = `staging`
- **Production**: `TF_VAR_environment` = `production`

**Screenshot Location**: `screenshots/19-variables-list.png`
*[Screenshot should show: List of repository and environment variables]*

---

## Step 6: Verify Secrets in Workflows

### 6.1 Complete Workflow Examples

Here are complete GitHub Actions workflow examples showing how secrets and environment variables are used:

#### Example 1: Terraform Validation Workflow

**File**: `.github/workflows/terraform-validate.yml`

```yaml
name: Terraform Validation

on:
  pull_request:
    paths:
      - '**.tf'
      - '**.tfvars'
      - '.github/workflows/**'
  workflow_dispatch:

jobs:
  validate:
    name: Validate Terraform
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.5.0"

      - name: Terraform Format Check
        id: fmt
        run: terraform fmt -check
        continue-on-error: true

      - name: Terraform Init
        run: terraform init -backend=false

      - name: Terraform Validate
        id: validate
        run: terraform validate -no-color
        continue-on-error: true

      - name: Comment PR
        uses: actions/github-script@v7
        if: github.event_name == 'pull_request'
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}  # ← Built-in secret
          script: |
            const output = `#### Terraform Validation Results
            - Format: ${{ steps.fmt.outcome }}
            - Validate: ${{ steps.validate.outcome }}`;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })
```

**Key Points:**
- Uses `${{ secrets.GITHUB_TOKEN }}` - Built-in secret provided by GitHub
- No Azure authentication needed for validation (uses `-backend=false`)
- Comments on PR with validation results

**Screenshot Location**: `screenshots/21-validation-workflow.png`
*[Screenshot should show: GitHub Actions workflow run for validation, showing successful steps]*

---

#### Example 2: Terraform Plan Workflow (Uses Azure Secrets)

**File**: `.github/workflows/terraform-plan.yml`

```yaml
name: Terraform Plan

on:
  pull_request:
    branches:
      - main
    paths:
      - '**.tf'
      - '**.tfvars'
  workflow_dispatch:

env:
  TF_VERSION: "1.5.0"  # ← Environment variable (non-sensitive)

jobs:
  plan:
    name: Terraform Plan
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}  # ← Using env variable
          terraform_wrapper: false

      - name: Configure Azure credentials
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}  # ← Using repository secret

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        id: plan
        run: terraform plan -no-color -out=tfplan
        continue-on-error: true

      - name: Save Plan Artifact
        uses: actions/upload-artifact@v4
        if: steps.plan.outcome == 'success'
        with:
          name: terraform-plan
          path: tfplan

      - name: Comment PR
        uses: actions/github-script@v7
        if: github.event_name == 'pull_request'
        env:
          PLAN: "${{ steps.plan.outputs.stdout }}"
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}  # ← Built-in secret
          script: |
            const output = `#### Terraform Plan 📖
            <details><summary>Show Plan</summary>
            
            \`\`\`terraform
            ${process.env.PLAN}
            \`\`\`
            
            </details>`;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })
```

**Key Points:**
- Uses `${{ secrets.AZURE_CREDENTIALS }}` for Azure authentication
- Uses `${{ env.TF_VERSION }}` for Terraform version (non-sensitive)
- Uses `${{ secrets.GITHUB_TOKEN }}` for PR comments
- Stores plan as artifact for later use

**Screenshot Location**: `screenshots/22-plan-workflow.png`
*[Screenshot should show: GitHub Actions workflow run for plan, showing Azure login step and plan output]*

---

#### Example 3: Terraform Apply Workflow (Uses Environment Secrets)

**File**: `.github/workflows/terraform-apply.yml`

```yaml
name: Terraform Apply

on:
  push:
    branches:
      - main
    paths:
      - '**.tf'
      - '**.tfvars'
  workflow_dispatch:

env:
  TF_VERSION: "1.5.0"
  WORKING_DIR: "./terraform"  # ← Environment variable

jobs:
  apply:
    name: Terraform Apply
    runs-on: ubuntu-latest
    environment: production  # ← Uses production environment secrets
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
          terraform_wrapper: false

      - name: Configure Azure credentials
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}  # ← Uses production environment secret

      - name: Terraform Init
        run: terraform init
        working-directory: ${{ env.WORKING_DIR }}

      - name: Terraform Apply
        id: apply
        run: terraform apply -auto-approve
        working-directory: ${{ env.WORKING_DIR }}
        continue-on-error: true

      - name: Terraform Output
        if: steps.apply.outcome == 'success'
        run: terraform output -json > outputs.json
        working-directory: ${{ env.WORKING_DIR }}

      - name: Upload Outputs
        if: steps.apply.outcome == 'success'
        uses: actions/upload-artifact@v4
        with:
          name: terraform-outputs
          path: ${{ env.WORKING_DIR }}/outputs.json
```

**Key Points:**
- Uses `environment: production` - Requires approval and uses production secrets
- Uses `${{ secrets.AZURE_CREDENTIALS }}` - Will use production environment secret if it exists
- Uses `${{ env.WORKING_DIR }}` - Environment variable for directory path
- Requires manual approval before running (if configured)

**Screenshot Location**: `screenshots/23-apply-workflow-pending.png`
*[Screenshot should show: Workflow run waiting for approval with "Review deployments" button]*

**Screenshot Location**: `screenshots/24-apply-workflow-approved.png`
*[Screenshot should show: Workflow run after approval, showing apply steps running]*

---

#### Example 4: Using Individual ARM Secrets

If you prefer individual secrets instead of `AZURE_CREDENTIALS`:

```yaml
name: Terraform Plan

on:
  pull_request:
    branches:
      - main

jobs:
  plan:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.5.0"
        env:
          # ← Using individual ARM secrets
          ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
          ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
          ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan
```

**Key Points:**
- Sets ARM environment variables from secrets
- Terraform Azure provider automatically reads these variables
- No need for `azure/login@v1` action when using ARM_* variables

---

#### Example 5: Using Environment Variables

```yaml
name: Terraform Deploy

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        type: choice
        options:
          - dev
          - staging
          - production

env:
  TF_VERSION: ${{ vars.TF_VERSION }}  # ← Repository variable
  DEFAULT_LOCATION: ${{ vars.DEFAULT_LOCATION }}  # ← Repository variable

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}  # ← Dynamic environment
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Terraform Apply
        env:
          # ← Using environment-specific variables
          TF_VAR_environment: ${{ vars.TF_VAR_environment }}
          TF_VAR_location: ${{ vars.DEFAULT_LOCATION }}
        run: |
          terraform init
          terraform apply -auto-approve
```

**Key Points:**
- Uses `${{ vars.VARIABLE_NAME }}` for environment variables
- Dynamic environment selection via workflow inputs
- Environment-specific variables override repository variables

---

### 6.2 Secret Syntax Reference

**Repository Secrets:**
```yaml
${{ secrets.SECRET_NAME }}
```

**Environment Secrets** (when using `environment:`):
```yaml
environment: production
# Then use:
${{ secrets.SECRET_NAME }}  # Uses environment secret if exists, else repository secret
```

**Environment Variables:**
```yaml
${{ vars.VARIABLE_NAME }}
```

**Built-in Secrets:**
```yaml
${{ secrets.GITHUB_TOKEN }}  # Automatically provided by GitHub
```

**Environment Context:**
```yaml
${{ env.VARIABLE_NAME }}  # Variables defined in workflow env: section
```

### 6.3 Secret Precedence

When the same secret exists at multiple levels:
1. **Environment secret** (highest priority) - Used when `environment:` is specified
2. **Repository secret** (fallback) - Used if environment secret doesn't exist

**Example:**
```yaml
jobs:
  deploy:
    environment: production  # ← Specifies environment
    steps:
      - run: echo ${{ secrets.ARM_SUBSCRIPTION_ID }}
      # Uses production environment secret if it exists
      # Falls back to repository secret if not
```

### 6.3 Secret Precedence

When the same secret exists at multiple levels:
1. **Environment secret** (highest priority)
2. **Repository secret** (fallback)

**Example:**
- Repository secret: `ARM_SUBSCRIPTION_ID` = `dev-sub-id`
- Production environment secret: `ARM_SUBSCRIPTION_ID` = `prod-sub-id`
- Workflow using `environment: production` → Uses `prod-sub-id`

### 6.4 Testing Secrets

Create a test workflow to verify secrets are accessible:

**File**: `.github/workflows/test-secrets.yml`

```yaml
name: Test Secrets

on:
  workflow_dispatch:  # Manual trigger

jobs:
  test:
    runs-on: ubuntu-latest
    environment: production  # Test with production environment
    
    steps:
      - name: Test Secret Access
        run: |
          echo "Testing secret access..."
          
          # Test repository secrets
          if [ -z "${{ secrets.ARM_CLIENT_ID }}" ]; then
            echo "❌ ARM_CLIENT_ID not set"
            exit 1
          else
            echo "✅ ARM_CLIENT_ID is set (value is masked)"
          fi
          
          # Test environment variables
          if [ -z "${{ vars.TF_VERSION }}" ]; then
            echo "⚠️ TF_VERSION variable not set"
          else
            echo "✅ TF_VERSION = ${{ vars.TF_VERSION }}"
          fi
          
          # Test built-in secret
          if [ -z "${{ secrets.GITHUB_TOKEN }}" ]; then
            echo "❌ GITHUB_TOKEN not available"
            exit 1
          else
            echo "✅ GITHUB_TOKEN is available"
          fi
```

**Note**: Secret values are automatically masked in workflow logs. You'll see `***` instead of actual values.

**Screenshot Location**: `screenshots/25-test-secrets-workflow.png`
*[Screenshot should show: Test workflow run showing masked secret values in logs]*

### 6.5 Viewing Workflow Runs

After setting up secrets and workflows:

1. Go to your repository
2. Click on **Actions** tab
3. You'll see workflow runs listed
4. Click on a workflow run to see details

**Screenshot Location**: `screenshots/26-actions-tab.png`
*[Screenshot should show: GitHub Actions tab with list of workflow runs]*

**Screenshot Location**: `screenshots/27-workflow-run-details.png`
*[Screenshot should show: Workflow run details showing steps, with secret values masked]*

### 6.6 Workflow File Location

Workflow files must be placed in:
```
.github/workflows/
```

**Example structure:**
```
repository/
├── .github/
│   └── workflows/
│       ├── terraform-validate.yml
│       ├── terraform-plan.yml
│       └── terraform-apply.yml
├── main.tf
├── variables.tf
└── ...
```

**Screenshot Location**: `screenshots/28-workflow-files-location.png`
*[Screenshot should show: Repository file tree with .github/workflows/ directory and workflow files]*

---

## Best Practices

### 1. **Never Commit Secrets**
- ✅ Use GitHub Secrets
- ❌ Never hardcode secrets in workflow files
- ❌ Never commit `.tfvars` files with secrets
- ❌ Never store secrets in code comments

### 2. **Use Environment-Specific Secrets**
- Create separate environments for dev/staging/prod
- Use environment secrets for environment-specific values
- Use repository secrets for shared values

### 3. **Limit Secret Access**
- Only grant access to workflows that need secrets
- Use environment protection rules for production
- Regularly audit who has access

### 4. **Rotate Secrets Regularly**
- Set expiration dates for service principals
- Rotate secrets every 90 days (or per policy)
- Update GitHub secrets when rotating

### 5. **Use Descriptive Names**
- Name secrets clearly (e.g., `ARM_CLIENT_ID` not `secret1`)
- Follow naming conventions
- Document secret purposes

### 6. **Separate Secrets from Variables**
- Use **Secrets** for sensitive data (passwords, keys)
- Use **Variables** for non-sensitive config (regions, prefixes)

### 7. **Review Secret Usage**
- Regularly review which workflows use which secrets
- Remove unused secrets
- Document secret dependencies

---

## Troubleshooting

### Issue: "Secret not found" Error

**Problem**: Workflow can't access a secret

**Solutions:**
1. **Verify secret name** - Check for typos (case-sensitive)
2. **Check environment** - Ensure workflow specifies correct environment
3. **Verify secret exists** - Go to Settings > Secrets and confirm
4. **Check permissions** - Ensure workflow has access to secrets

**Example Error:**
```
Error: The secret 'ARM_CLIENT_ID' is not set
```

**Fix:**
- Go to Settings > Secrets and variables > Actions
- Verify `ARM_CLIENT_ID` exists
- Check spelling matches exactly (case-sensitive)

### Issue: Secret Value is Empty

**Problem**: Secret exists but value is empty

**Solutions:**
1. **Re-add secret** - Delete and recreate with correct value
2. **Check JSON format** - For `AZURE_CREDENTIALS`, ensure valid JSON
3. **Verify no extra spaces** - Copy/paste might include hidden characters

### Issue: Environment Secret Not Used

**Problem**: Workflow uses repository secret instead of environment secret

**Solutions:**
1. **Check environment** - Ensure workflow specifies `environment: name`
2. **Verify environment secret exists** - Check environment settings
3. **Check secret name** - Must match exactly (case-sensitive)

**Example:**
```yaml
jobs:
  deploy:
    environment: production  # ← Must specify environment
    steps:
      - run: echo ${{ secrets.ARM_SUBSCRIPTION_ID }}
```

### Issue: Secret Masked in Logs (Expected Behavior)

**Problem**: Can't see secret value in workflow logs

**This is correct!** Secrets are automatically masked. You'll see:
```
ARM_CLIENT_ID=***
```

**To verify secret is set:**
- Check if workflow runs successfully
- Use conditional logic to test secret existence
- Never try to print secret values

### Issue: JSON Format Error (AZURE_CREDENTIALS)

**Problem**: `AZURE_CREDENTIALS` secret causes authentication errors

**Solutions:**
1. **Verify JSON format** - Must be valid JSON
2. **Check for extra characters** - No trailing commas
3. **Use individual secrets** - Consider using `ARM_CLIENT_ID`, etc. instead

**Correct Format:**
```json
{
  "clientId": "12345678-1234-1234-1234-123456789012",
  "clientSecret": "secret-value",
  "subscriptionId": "87654321-4321-4321-4321-210987654321",
  "tenantId": "11111111-2222-3333-4444-555555555555"
}
```

### Issue: Environment Protection Rules Blocking Deployment

**Problem**: Deployment waiting for approval

**Solutions:**
1. **Check required reviewers** - Ensure reviewers are available
2. **Review deployment** - Go to Actions tab and approve
3. **Adjust protection rules** - Temporarily disable for testing (not recommended for production)

**Screenshot Location**: `screenshots/20-pending-approval.png`
*[Screenshot should show: Workflow run waiting for approval with "Review deployments" button]*

---

## Quick Reference

### Secret Syntax in Workflows

```yaml
# Repository secret
${{ secrets.SECRET_NAME }}

# Environment secret (when using environment)
${{ secrets.SECRET_NAME }}

# Environment variable
${{ vars.VARIABLE_NAME }}
```

### Common Azure Secrets

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AZURE_CREDENTIALS` | Complete Azure credentials JSON | `{"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"..."}` |
| `ARM_CLIENT_ID` | Service principal client ID | `12345678-1234-1234-1234-123456789012` |
| `ARM_CLIENT_SECRET` | Service principal secret | `your-secret-value` |
| `ARM_SUBSCRIPTION_ID` | Azure subscription ID | `87654321-4321-4321-4321-210987654321` |
| `ARM_TENANT_ID` | Azure tenant ID | `11111111-2222-3333-4444-555555555555` |

### Where to Find Secrets

1. **Repository Secrets**: Settings > Secrets and variables > Actions > Secrets
2. **Environment Secrets**: Settings > Environments > [Environment Name] > Environment secrets
3. **Repository Variables**: Settings > Secrets and variables > Actions > Variables
4. **Environment Variables**: Settings > Environments > [Environment Name] > Environment variables

---

## Summary

In this guide, you learned:
- ✅ How to add repository secrets
- ✅ How to create GitHub environments
- ✅ How to add environment-specific secrets
- ✅ How to add environment variables
- ✅ How to use secrets in workflows
- ✅ Best practices for secret management
- ✅ Troubleshooting common issues

**Next Steps:**
- Set up secrets for your Terraform workflows
- Create environments for dev/staging/production
- Configure your workflows to use secrets securely

---

## Screenshot Checklist

For instructors creating screenshots, capture these views:

1. ✅ Repository Settings tab
2. ✅ Secrets and variables menu
3. ✅ Empty secrets tab
4. ✅ New secret form
5. ✅ AZURE_CREDENTIALS secret filled
6. ✅ List of individual ARM secrets
7. ✅ Created secrets list
8. ✅ Environments menu
9. ✅ New environment dialog
10. ✅ Environment configuration page
11. ✅ Required reviewers section
12. ✅ Multiple environments list
13. ✅ Environment secrets section
14. ✅ Add environment secret form
15. ✅ Environment-specific secrets
16. ✅ Variables tab
17. ✅ New variable form
18. ✅ Environment variables section
19. ✅ Variables list
20. ✅ Pending approval workflow

**Screenshot Tips:**
- Use clear, high-resolution images
- Highlight relevant UI elements with arrows or boxes
- Include browser address bar to show context
- Mask any sensitive information visible in screenshots
- Use consistent browser theme/zoom level

