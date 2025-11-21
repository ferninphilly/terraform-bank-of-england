# Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                = "${var.name_prefix}-vm-${random_id.suffix.hex}"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  size = local.vm_size

  admin_username = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  # Disable password authentication, use SSH keys
  disable_password_authentication = var.disable_password_authentication

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh.public_key_openssh
  }

  # OS Disk
  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = local.storage_account_type
  }

  # Source Image
  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  # Boot diagnostics
  boot_diagnostics {
    storage_account_uri = var.enable_boot_diagnostics ? null : null
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Module      = var.module_tag
    VM_Size     = local.vm_size
  })

  # Ansible Provisioner - Remote Exec
  provisioner "remote-exec" {
    inline = var.remote_exec_inline_commands

    connection {
      type        = "ssh"
      user        = var.admin_username
      private_key = tls_private_key.ssh.private_key_pem
      host        = azurerm_public_ip.main.ip_address
    }
  }

  # Ansible Local Provisioner
  provisioner "local-exec" {
    command = var.enable_ansible ? <<-EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
        -i ${azurerm_public_ip.main.ip_address}, \
        -u ${var.admin_username} \
        --private-key ${path.module}/.ssh/id_rsa \
        -e "ansible_python_interpreter=${var.ansible_python_interpreter}" \
        -e "install_nginx=${var.install_nginx}" \
        -e "install_docker=${var.install_docker}" \
        ${path.module}/${var.ansible_playbook_path}
    EOT : var.ansible_skip_message
  }

  depends_on = [
    azurerm_network_interface.main,
    local_file.private_key,
  ]
}

