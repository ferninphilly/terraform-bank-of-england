# Basic Resource Tests
# These tests validate that resources are created correctly

run "resource_group_created" {
  command = plan

  assert {
    condition     = azurerm_resource_group.example != null
    error_message = "Resource group should be created"
  }
}

run "resource_group_has_correct_name" {
  command = plan

  variables {
    resource_group_name = "rg-test-validation"
  }

  assert {
    condition     = azurerm_resource_group.example.name == "rg-test-validation"
    error_message = "Resource group name should match the variable value"
  }
}

run "resource_group_has_location" {
  command = plan

  assert {
    condition     = azurerm_resource_group.example.location != ""
    error_message = "Resource group should have a location"
  }
}

run "storage_account_created" {
  command = plan

  assert {
    condition     = azurerm_storage_account.example != null
    error_message = "Storage account should be created"
  }
}

run "storage_account_name_length" {
  command = plan

  assert {
    condition     = length(azurerm_storage_account.example.name) <= 24
    error_message = "Storage account name must be 24 characters or less"
  }
}

run "storage_account_name_lowercase" {
  command = plan

  assert {
    condition     = azurerm_storage_account.example.name == lower(azurerm_storage_account.example.name)
    error_message = "Storage account name must be lowercase"
  }
}

run "storage_account_in_resource_group" {
  command = plan

  assert {
    condition     = azurerm_storage_account.example.resource_group_name == azurerm_resource_group.example.name
    error_message = "Storage account should be in the same resource group"
  }
}

