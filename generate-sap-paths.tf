# List SAP PATHS
resource "local_file" "KIT_SAP_PATHS" {
  content = <<-DOC
${var.kit_sapcar_file}
${var.kit_swpm_file}
${var.kit_saphotagent_file}
${var.kit_hdbclient_file}

    DOC
  filename = "modules/precheck-ssh-exec/sap-paths-${var.HOSTNAME}"
}