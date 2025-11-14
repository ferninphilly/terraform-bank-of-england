# Output Tests
# These tests validate that outputs are correct

run "resource_group_name_output" {
  command = plan

  assert {
    condition     = output.resource_group_name == azurerm_resource_group.example.name
    error_message = "Resource group name output should match the resource name"
  }
}

run "storage_account_name_output" {
  command = plan

  assert {
    condition     = output.storage_account_name == azurerm_storage_account.example.name
    error_message = "Storage account name output should match the resource name"
  }
}

run "storage_account_id_output" {
  command = plan

  assert {
    condition     = output.storage_account_id != null
    error_message = "Storage account ID output should not be null"
  }
}

run "vnet_output_when_created" {
  command = plan

  variables {
    create_vnet = true
  }

  assert {
    condition     = output.vnet_id != null
    error_message = "VNet ID output should not be null when VNet is created"
  }
}

run "vnet_output_when_not_created" {
  command = plan

  variables {
    create_vnet = false
  }

  assert {
    condition     = output.vnet_id == null
    error_message = "VNet ID output should be null when VNet is not created"
  }
}

