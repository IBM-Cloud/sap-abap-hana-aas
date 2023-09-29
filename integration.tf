# Export Terraform variable values to an Ansible var_file
resource "local_file" "tf_ansible_vars_generated_file" {
  content = <<-DOC
---
#Ansible vars_file containing variable values passed from Terraform.
#Generated by "terraform plan&apply" command.

#SAP system configuration
sap_sid: "${var.SAP_SID}"
sap_ci_host: "${var.SAP_CI_HOST}"
sap_ci_hostname: "${var.SAP_CI_HOSTNAME}"
sap_ci_instance_number: "${var.SAP_CI_INSTANCE_NUMBER}"
sap_ascs_instance_number: "${var.SAP_ASCS_INSTANCE_NUMBER}"
sap_aas_host: "${module.vsi.PRIVATE-IP}"
sap_aas_hostname: "${var.HOSTNAME}"
hdb_instance_number: "${var.HDB_INSTANCE_NUMBER}"
sap_aas_instance_number: "${var.SAP_AAS_INSTANCE_NUMBER}"
sap_main_password: "${var.SAP_MAIN_PASSWORD}"

#Kits paths
kit_sapcar_file: "${var.KIT_SAPCAR_FILE}"
kit_swpm_file: "${var.KIT_SWPM_FILE}"
kit_saphotagent_file: "${var.KIT_SAPHOSTAGENT_FILE}"
kit_hdbclient_file: "${var.KIT_HDBCLIENT_FILE}"
...
    DOC
  filename = "ansible/sapnwhdb-aas-vars.yml"
}
