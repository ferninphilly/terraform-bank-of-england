# Local values for computed configurations

locals {
  # VM Size selection based on environment
  vm_size = var.vm_size != "" ? var.vm_size : (
    var.environment == "prod" ? var.vm_size_prod : (
      var.environment == "staging" ? var.vm_size_staging : var.vm_size_dev
    )
  )

  # Storage account type based on environment
  storage_account_type = var.environment == "prod" ? var.storage_account_type_prod : var.storage_account_type_dev

  # Alert severity based on environment
  alert_severity = var.environment == "prod" ? var.alert_severity_prod : var.alert_severity_dev
}

