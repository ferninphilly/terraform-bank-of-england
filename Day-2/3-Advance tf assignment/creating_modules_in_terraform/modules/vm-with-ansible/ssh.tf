# Generate SSH key pair
resource "tls_private_key" "ssh" {
  algorithm = var.ssh_key_algorithm
  rsa_bits  = var.ssh_key_rsa_bits
}

# Save private key locally (for Ansible)
resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/.ssh/id_rsa"
  file_permission = var.ssh_private_key_permissions
}

# Save public key locally
resource "local_file" "public_key" {
  content  = tls_private_key.ssh.public_key_openssh
  filename = "${path.module}/.ssh/id_rsa.pub"
}

