# This is the entrypoint for Terraform.

# Example: Null resource to trigger a local script or Ansible playbook
resource "null_resource" "trigger_ansible" {
  provisioner "local-exec" {
    # This command simply echoes a message to show Terraform works.
    # In reality, it could trigger Ansible: command = "ansible-playbook -i ../ansible/inventories/local.ini ..."
    command = "echo Terraform is running and ready to trigger Ansible!"
  }
}
