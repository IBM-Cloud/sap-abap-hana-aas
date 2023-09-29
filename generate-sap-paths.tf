# List SAP PATHS
resource "local_file" "KIT_SAP_PATHS" {
  content = <<-DOC
${var.KIT_SAPCAR_FILE}
${var.KIT_SWPM_FILE}
${var.KIT_SAPHOSTAGENT_FILE}
${var.KIT_HDBCLIENT_FILE}

    DOC
  filename = "modules/precheck-ssh-exec/sap-paths-${var.HOSTNAME}"
}
