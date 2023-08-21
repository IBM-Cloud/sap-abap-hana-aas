variable "private_ssh_key" {
	type		= string
	description = "Required only for Schematics Deployments - Input your id_rsa private key pair content in OpenSSH format (Sensitive* value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment."
	nullable = false
	validation {
	condition = length(var.private_ssh_key) >= 64 && var.private_ssh_key != null && length(var.private_ssh_key) != 0 || contains(["n.a"], var.private_ssh_key )
	error_message = "The content for private_ssh_key variable must be completed in OpenSSH format."
      }
}

variable "ID_RSA_FILE_PATH" {
    default = "ansible/id_rsa"
    nullable = false
    description = "The file path for private_ssh_key will be automatically generated by default. If it is changed, it must contain the relative path from git repo folders."
}


variable "BASTION_FLOATING_IP" {
	type		= string
	description = "Required only for Schematics Deployments - The FLOATING IP from the Bastion Server."
	nullable = false
	validation {
        condition = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",var.BASTION_FLOATING_IP)) || contains(["localhost"], var.BASTION_FLOATING_IP ) && var.BASTION_FLOATING_IP!= null
        error_message = "Incorrect format for variable: BASTION_FLOATING_IP."
      }
}

variable "SSH_KEYS" {
	type		= list(string)
	description = "List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. Can contain one or more IDs. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys"
	validation {
		condition     = var.SSH_KEYS == [] ? false : true && var.SSH_KEYS == [""] ? false : true
		error_message = "At least one SSH KEY is needed to be able to access the VSI."
	}
}

variable "REGION" {
	type		= string
	description	= "The cloud region where to deploy the solution. The regions and zones for VPC are listed here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. Review supported locations in IBM Cloud Schematics here: https://cloud.ibm.com/docs/schematics?topic=schematics-locations"
	validation {
		condition     = contains(["au-syd", "jp-osa", "jp-tok", "eu-de", "eu-gb", "ca-tor", "us-south", "us-east", "br-sao"], var.REGION )
		error_message = "The REGION must be one of: au-syd, jp-osa, jp-tok, eu-de, eu-gb, ca-tor, us-south, us-east, br-sao."
	}
}

variable "ZONE" {
	type		= string
	description	= "The cloud zone where to deploy the solution."
	validation {
		condition     = length(regexall("^(eu-de|eu-gb|us-south|us-east)-(1|2|3)$", var.ZONE)) > 0
		error_message = "The ZONE is not valid."
	}
}

variable "VPC" {
	type		= string
	description = "The name of an EXISTING VPC. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPC)) > 0
		error_message = "The VPC name is not valid."
	}
}

variable "SUBNET" {
	type		= string
	description = "The name of an EXISTING Subnet. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SUBNET)) > 0
		error_message = "The SUBNET name is not valid."
	}
}

variable "SECURITY_GROUP" {
	type		= string
	description = "The name of an EXISTING Security group. The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SECURITY_GROUP)) > 0
		error_message = "The SECURITY_GROUP name is not valid."
	}
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "The name of an EXISTING Resource Group for VSIs and Volumes resources. The list of Resource Groups is available here: https://cloud.ibm.com/account/resource-groups"
  default     = "Default"
}

variable "HOSTNAME" {
	type		= string
	description = "The Hostname for the VSI. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)"
	validation {
		condition     = length(var.HOSTNAME) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.HOSTNAME)) > 0
		error_message = "The HOSTNAME is not valid."
	}
}

variable "PROFILE" {
	type		= string
	description = "The profile used for the VSI. A list of profiles is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles. For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211)."
	default		= "bx2-4x16"
}

variable "IMAGE" {
	type		= string
	description = "The OS image used for the VSI. A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images"
	default		= "ibm-redhat-8-4-amd64-sap-applications-2"
}

data "ibm_is_instance" "vsi" {
  depends_on = [module.vsi]
  name    =  var.HOSTNAME
}


variable "VOL1" {
	type		= string
	description = "Volume 1 Size - The size for the disks in GB that are to be attached to the VSI and used by SAP"
	default		= "40"
}

variable "VOL2" {
	type		= string
	description = "Volume 2 Size - The size for the disks in GB that are to be attached to the VSI and used by SAP"
	default		= "64"
}

variable "sap_sid" {
	type		= string
	description = "The SAP system ID identifies the entire SAP system."
	default		= "NWD"
}

variable "sap_ci_host" {
	type		= string
	description = "IP address of the existing SAP Central Instance"
}

variable "sap_ci_hostname" {
	type		= string
	description = "The hostname of the existing SAP Central Instance"
}

variable "sap_ci_instance_number" {
	type		= string
	description = "Technical identifier for internal processes of the Central Instance"
	default		= "00"
}

variable "sap_ascs_instance_number" {
	type		= string
	description = "Technical identifier for internal processes of ASCS"
	default		= "01"
}

variable "hdb_instance_number" {
	type		= string
	description = "The instance number of the SAP HANA database server"
	default		= "00"
}

variable "sap_aas_instance_number" {
	type		= string
	description = "Technical identifier for internal processes of the additional application server"
	default		= "00"
}

variable "sap_main_password" {
	type		= string
	sensitive = true
	description = "Common password for all users that are created during the installation (See Obs*)."
	validation {
		condition     = length(regexall("^(.{0,9}|.{15,}|[^0-9]*)$", var.sap_main_password)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z@#$_]+$", var.sap_main_password)) > 0
		error_message = "The sap_main_password is not valid."
	}
}

variable "kit_sapcar_file" {
	type		= string
	description = "Path to sapcar binary. As downloaded from SAP Support Portal"
	default		= "/storage/NW75HDB/SAPCAR_1010-70006178.EXE"
}

variable "kit_swpm_file" {
	type		= string
	description = "Path to SWPM archive (SAR). As downloaded from SAP Support Portal"
	default		= "/storage/NW75HDB/SWPM10SP31_7-20009701.SAR"
}

variable "kit_saphotagent_file" {
	type		= string
	description = "Path to SAP Host Agent archive (SAR). As downloaded from SAP Support Portal"
	default		= "/storage/NW75SHDB/SAPHOSTAGENT51_51-20009394.SAR"
}

variable "kit_hdbclient_file" {
	type		= string
	description = "Path to HANA DB client archive (SAR). As downloaded from SAP Support Portal"
	default		= "IMDB_CLIENT20_009_28-80002082.SAR"
}
