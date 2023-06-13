data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

resource "ibm_is_volume" "vol1" {
  name		= "${var.HOSTNAME}-vol1"
  profile	= "10iops-tier"
  zone		= var.ZONE
  resource_group = data.ibm_resource_group.group.id
  capacity	= var.VOL1
}

resource "ibm_is_volume" "vol2" {
  name		= "${var.HOSTNAME}-vol2"
  profile	= "10iops-tier"
  zone		= var.ZONE
  resource_group = data.ibm_resource_group.group.id
  capacity	= var.VOL2
}

output "volumes_list" {
  value       = [ ibm_is_volume.vol1.id , ibm_is_volume.vol2.id ]
}
