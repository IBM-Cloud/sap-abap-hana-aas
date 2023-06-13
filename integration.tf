# Export Terraform variable values to an Ansible var_file
resource "local_file" "tf_ansible_vars_generated_file" {
  content = <<-DOC
---
#Ansible vars_file containing variable values passed from Terraform.
#Generated by "terraform plan&apply" command.

#SAP system configuration
sap_sid: "${var.sap_sid}"
sap_ci_host: "${var.sap_ci_host}"
sap_ci_hostname: "${var.sap_ci_hostname}"
sap_ci_instance_number: "${var.sap_ci_instance_number}"
sap_ascs_instance_number: "${var.sap_ascs_instance_number}"
sap_aas_host: "${module.vsi.PRIVATE-IP}"
sap_aas_hostname: "${var.HOSTNAME}"
hdb_instance_number: "${var.hdb_instance_number}"
sap_aas_instance_number: "${var.sap_aas_instance_number}"
sap_main_password: "${var.sap_main_password}"

#Kits paths
kit_sapcar_file: "${var.kit_sapcar_file}"
kit_swpm_file: "${var.kit_swpm_file}"
kit_saphotagent_file: "${var.kit_saphotagent_file}"
kit_hdbclient_file: "${var.kit_hdbclient_file}"
...
    DOC
  filename = "ansible/sapnwhdb-aas-vars.yml"
}
