# Conditional Resource Tests
# These tests validate conditional resource creation

run "vnet_created_when_enabled" {
  command = plan

  variables {
    create_vnet = true
  }

  assert {
    condition     = length(azurerm_virtual_network.example) == 1
    error_message = "VNet should be created when create_vnet is true"
  }
}

run "vnet_not_created_when_disabled" {
  command = plan

  variables {
    create_vnet = false
  }

  assert {
    condition     = length(azurerm_virtual_network.example) == 0
    error_message = "VNet should not be created when create_vnet is false"
  }
}

run "vnet_has_correct_address_space" {
  command = plan

  variables {
    create_vnet        = true
    vnet_address_space = ["10.1.0.0/16"]
  }

  assert {
    condition     = azurerm_virtual_network.example[0].address_space[0] == "10.1.0.0/16"
    error_message = "VNet should have the correct address space"
  }
}

