# Validation Tests
# These tests validate business rules and constraints

run "storage_account_tier_validation" {
  command = plan

  variables {
    account_tier = "Standard"
  }

  assert {
    condition     = azurerm_storage_account.example.account_tier == "Standard"
    error_message = "Storage account tier should be Standard"
  }
}

run "storage_account_replication_validation" {
  command = plan

  variables {
    replication_type = "LRS"
  }

  assert {
    condition     = azurerm_storage_account.example.account_replication_type == "LRS"
    error_message = "Storage account replication type should be LRS"
  }
}

run "resource_group_location_validation" {
  command = plan

  variables {
    location = "eastus"
  }

  assert {
    condition     = azurerm_resource_group.example.location == "eastus"
    error_message = "Resource group location should match the variable"
  }
}

run "vnet_address_space_format" {
  command = plan

  variables {
    create_vnet        = true
    vnet_address_space = ["10.0.0.0/16"]
  }

  assert {
    condition     = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}/[0-9]{1,2}$", azurerm_virtual_network.example[0].address_space[0]))
    error_message = "VNet address space should be in CIDR notation"
  }
}

