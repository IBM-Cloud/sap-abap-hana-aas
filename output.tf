output "HOSTNAME" {
  value		= module.vsi.HOSTNAME
}

output "PRIVATE-IP" {
  value		= module.vsi.PRIVATE-IP
}

output "ATR_INSTANCE_NAME" {
  description = "Activity Tracker instance name."
  value       = var.ATR_NAME
}