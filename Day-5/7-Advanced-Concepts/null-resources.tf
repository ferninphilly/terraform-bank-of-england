# TODO: Exercise 1 - Null Resources and Provisioners
# - Create null resource with triggers
# - Use local-exec provisioner
# - Use remote-exec provisioner (if creating VMs)
# - Use file provisioner

# Example null resource:
# resource "null_resource" "example" {
#   triggers = {
#     always_run = timestamp()
#   }
#
#   provisioner "local-exec" {
#     command = "echo 'Resource created'"
#   }
# }

