resource "null_resource" "ansible-exec-ci" {

  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.IP}, ansible/sapnwhdb-ci.yml"
  }
}
