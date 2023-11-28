variable "PRIVATE_SSH_KEY" {
	type		= string
	description = "Required only for Schematics Deployments - Input your id_rsa private key pair content in OpenSSH format (Sensitive* value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment."
	nullable = false
	validation {
	condition = length(var.PRIVATE_SSH_KEY) >= 64 && var.PRIVATE_SSH_KEY != null && length(var.PRIVATE_SSH_KEY) != 0 || contains(["n.a"], var.PRIVATE_SSH_KEY )
	error_message = "The content for PRIVATE_SSH_KEY variable must be completed in OpenSSH format."
      }
}

variable "ID_RSA_FILE_PATH" {
    default = "ansible/id_rsa"
    nullable = false
    description = "The file path for PRIVATE_SSH_KEY will be automatically generated by default. If it is changed, it must contain the relative path from git repo folders."
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
        type            = string
        description     = "The cloud region where to deploy the solution. The regions and zones for VPC are listed here:https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. Review supported locations in IBM Cloud Schematics here: https://cloud.ibm.com/docs/schematics?topic=schematics-locations."
        validation {
                condition     = contains(["au-syd", "jp-osa", "jp-tok", "eu-de", "eu-gb", "ca-tor", "us-south", "us-east", "br-sao"], var.REGION )
                error_message = "For CLI deployments, the REGION must be one of: au-syd, jp-osa, jp-tok, eu-de, eu-gb, ca-tor, us-south, us-east, br-sao. \n For Schematics, the REGION must be one of: eu-de, eu-gb, us-south, us-east."
        }
}

variable "ZONE" {
        type            = string
        description     = "The cloud zone where to deploy the solution."
        validation {
                condition     = length(regexall("^(au-syd|jp-osa|jp-tok|eu-de|eu-gb|ca-tor|us-south|us-east|br-sao)-(1|2|3)$", var.ZONE)) > 0
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

##############################################################
# The variables used in Activity Tracker service.
##############################################################

variable "ATR_NAME" {
  type        = string
  description = "The name of the EXISTING Activity Tracker instance, in the same region as HANA VSI. The list of available Activity Tracker is available here: https://cloud.ibm.com/observe/activitytracker"
  default = ""
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
	default		= "ibm-redhat-8-6-amd64-sap-applications-4"
}

data "ibm_is_instance" "vsi" {
  depends_on = [module.vsi]
  name    =  var.HOSTNAME
}


variable "SAP_SID" {
	type		= string
	description = "The SAP system ID. Identifies the entire SAP system. The SAP SID must be the same as the one on the primary application server (SAP CI HOST). Consists of exactly three alphanumeric characters and the first character must be a letter. Does not include any of the reserved IDs listed in SAP Note 1979280"
	default		= "NWD"
}

variable "SAP_CI_HOST" {
	type		= string
	description = "IP address of the existing SAP Central Instance"
}

variable "SAP_CI_HOSTNAME" {
	type		= string
	description = "The hostname of the existing SAP Central Instance"
}

variable "SAP_CI_INSTANCE_NUMBER" {
	type		= string
	description = "The SAP central instance number. Technical identifier for internal processes of CI. Consists of a two-digit number from 00 to 97. Must be unique on a host. Must follow the SAP rules for instance number naming"
	default		= "00"
}

variable "SAP_ASCS_INSTANCE_NUMBER" {
	type		= string
	description = "The central ABAP service instance number. Technical identifier for internal processes of ASCS. Consists of a two-digit number from 00 to 97. Must be unique on a host. Must follow the SAP rules for instance number naming"
	default		= "01"
}

variable "HDB_INSTANCE_NUMBER" {
	type		= string
	description = "The instance number of the SAP HANA database server"
	default		= "00"
}

variable "SAP_AAS_INSTANCE_NUMBER" {
	type		= string
	description = "The SAP additional application server instance number. Technical identifier for internal processes of AAS. Consists of a two-digit number from 00 to 97. Must be unique on a host. Must follow the SAP rules for instance number naming"
	default		= "00"
}

variable "SAP_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "Common password for all users that are created during the installation. It must be 10 to 14 characters long. It must contain at least one digit (0-9). It can only contain the following characters: a-z, A-Z, 0-9, @, #, $, _. It must not start with a digit or an underscore ( _ )"
	validation {
		condition     = length(regexall("^(.{0,9}|.{15,}|[^0-9]*)$", var.SAP_MAIN_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z@#$_]+$", var.SAP_MAIN_PASSWORD)) > 0
		error_message = "The SAP_MAIN_PASSWORD is not valid."
	}
}

variable "KIT_SAPCAR_FILE" {
	type		= string
	description = "Path to sapcar binary. As downloaded from SAP Support Portal"
	default		= "/storage/NW75HDB/SAPCAR_1010-70006178.EXE"
}

variable "KIT_SWPM_FILE" {
	type		= string
	description = "Path to SWPM archive (SAR). As downloaded from SAP Support Portal"
	default		= "/storage/NW75HDB/SWPM10SP31_7-20009701.SAR"
}

variable "KIT_SAPHOSTAGENT_FILE" {
	type		= string
	description = "Path to SAP Host Agent archive (SAR). As downloaded from SAP Support Portal"
	default		= "/storage/NW75HDB/SAPHOSTAGENT51_51-20009394.SAR"
}

variable "KIT_HDBCLIENT_FILE" {
	type		= string
	description = "Path to HANA DB client archive (SAR). As downloaded from SAP Support Portal"
	default		= "/storage/NW75HDB/IMDB_CLIENT20_009_28-80002082.SAR"
}

# ATR variable and conditions
locals {
        VOL1 = 40
	VOL2 = 64
	ATR_ENABLE = true
}

resource "null_resource" "check_atr_name" {
  count             = local.ATR_ENABLE == true ? 1 : 0
  lifecycle {
    precondition {
      condition     = var.ATR_NAME != "" && var.ATR_NAME != null
      error_message = "The name of an EXISTENT Activity Tracker in the same region must be specified."
    }
  }
}

data "ibm_resource_instance" "activity_tracker" {
  count             = local.ATR_ENABLE == true ? 1 : 0
  name              = var.ATR_NAME
  location          = var.REGION
  service           = "logdnaat"
}


