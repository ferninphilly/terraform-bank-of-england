# Reads credentials from sp_output.json and sets environment variables for PowerShell.

Write-Host "Reading credentials from sp_output.json..."

# Check if the credentials file exists
if (-not (Test-Path ".\sp_output.json")) {
    Write-Host "Error: 'sp_output.json' not found." -ForegroundColor Red
    Write-Host "Please ensure you run Step 1 and pipe the output to this file." -ForegroundColor Red
    exit
}

# Load the JSON file contents
$jsonContent = Get-Content -Path ".\sp_output.json" | ConvertFrom-Json

# Set environment variables
$env:ARM_CLIENT_ID = $jsonContent.appId
$env:ARM_CLIENT_SECRET = $jsonContent.password
$env:ARM_TENANT_ID = $jsonContent.tenant

# Get the Subscription ID using the Azure CLI
$env:ARM_SUBSCRIPTION_ID = (az account show --query id -o tsv).Trim()

Write-Host "Success! Environment variables set for Terraform." -ForegroundColor Green
Write-Host "ARM_CLIENT_ID: $($env:ARM_CLIENT_ID)"
Write-Host "ARM_TENANT_ID: $($env:ARM_TENANT_ID)"