# Tag Tests
# These tests validate that tags are applied correctly

run "resources_have_tags" {
  command = plan

  variables {
    common_tags = {
      Environment = "test"
      ManagedBy   = "Terraform"
      Project     = "Testing"
    }
  }

  assert {
    condition     = azurerm_resource_group.example.tags["Environment"] == "test"
    error_message = "Resource group should have Environment tag"
  }

  assert {
    condition     = azurerm_resource_group.example.tags["ManagedBy"] == "Terraform"
    error_message = "Resource group should have ManagedBy tag"
  }

  assert {
    condition     = azurerm_storage_account.example.tags["Environment"] == "test"
    error_message = "Storage account should have Environment tag"
  }
}

run "tags_applied_to_all_resources" {
  command = plan

  variables {
    common_tags = {
      TestTag = "test-value"
    }
  }

  assert {
    condition     = azurerm_resource_group.example.tags["TestTag"] == "test-value"
    error_message = "Resource group should have TestTag"
  }

  assert {
    condition     = azurerm_storage_account.example.tags["TestTag"] == "test-value"
    error_message = "Storage account should have TestTag"
  }
}

