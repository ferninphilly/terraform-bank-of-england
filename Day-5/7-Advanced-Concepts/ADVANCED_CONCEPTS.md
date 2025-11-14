# Advanced Terraform Concepts Guide

## Null Resources

Null resources are useful for:
- Triggering other resources
- Running provisioners without a real resource
- Creating dependencies

```hcl
resource "null_resource" "example" {
  triggers = {
    timestamp = timestamp()
    value     = var.some_value
  }

  provisioner "local-exec" {
    command = "echo 'Triggered'"
  }
}
```

## Provisioners

### Local-Exec
Runs commands on the machine running Terraform:
```hcl
provisioner "local-exec" {
  command = "bash script.sh"
  environment = {
    VAR = "value"
  }
}
```

### Remote-Exec
Runs commands on the created resource:
```hcl
provisioner "remote-exec" {
  inline = [
    "sudo apt-get update",
    "sudo apt-get install -y nginx"
  ]
}
```

### File Provisioner
Copies files to the resource:
```hcl
provisioner "file" {
  source      = "config.conf"
  destination = "/etc/config.conf"
}
```

**Important**: Provisioners are a last resort. Prefer:
- Cloud-init/user data
- Configuration management tools
- Custom images

## Advanced Functions

### Collection Functions
```hcl
# Flatten nested lists
flatten([["a", "b"], ["c"]])  # ["a", "b", "c"]

# Create map from keys and values
zipmap(["a", "b"], [1, 2])  # {"a" = 1, "b" = 2}

# Cartesian product
setproduct(["a", "b"], [1, 2])  # [["a", 1], ["a", 2], ["b", 1], ["b", 2]]
```

### String Functions
```hcl
# Regex match
regex("([0-9]+)", "version-123")  # "123"

# Regex all matches
regexall("([0-9]+)", "version-123-build-456")  # ["123", "456"]

# Replace
replace("hello world", "world", "terraform")  # "hello terraform"
```

### Type Conversion
```hcl
tostring(123)    # "123"
tonumber("456")  # 456
tobool("true")   # true
```

## Secret Management

### Azure Key Vault
```hcl
# Store secret
resource "azurerm_key_vault_secret" "example" {
  name         = "my-secret"
  value        = var.secret_value
  key_vault_id = azurerm_key_vault.example.id
}

# Retrieve secret
data "azurerm_key_vault_secret" "example" {
  name         = "my-secret"
  key_vault_id = azurerm_key_vault.example.id
}
```

### Sensitive Variables
```hcl
variable "password" {
  type      = string
  sensitive = true
}

output "password" {
  value     = var.password
  sensitive = true
}
```

## External Data Sources

### External Script
```hcl
data "external" "example" {
  program = ["bash", "scripts/get-data.sh"]
  
  query = {
    param = "value"
  }
}
```

Script must output valid JSON to stdout.

### HTTP Data Source
```hcl
data "http" "example" {
  url = "https://api.example.com/data"
  
  request_headers = {
    Authorization = "Bearer ${var.token}"
  }
}
```

### TLS Data Source
```hcl
data "tls_certificate" "example" {
  url = "https://example.com"
}
```

## Best Practices

1. **Avoid Provisioners When Possible**
   - Use cloud-init/user data
   - Use configuration management
   - Build custom images

2. **Handle Secrets Properly**
   - Never commit secrets
   - Use secret management tools
   - Mark sensitive data

3. **Validate External Data**
   - Handle failures gracefully
   - Cache when appropriate
   - Document dependencies

4. **Use Functions Wisely**
   - Keep expressions readable
   - Document complex logic
   - Test function combinations

