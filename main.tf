module "pre-init-schematics" {
  source  = "./modules/pre-init"
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
}

module "pre-init-cli" {
  source  = "./modules/pre-init/cli"
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 1 : 0)
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
}

module "precheck-ssh-exec" {
  source  = "./modules/precheck-ssh-exec"
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  depends_on	= [ module.pre-init-schematics ]
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
  HOSTNAME  = var.HOSTNAME
  SECURITY_GROUP = var.SECURITY_GROUP
  
}

module "vpc-subnet" {
  source		= "./modules/vpc/subnet"
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
}


module "volumes" {
  source		= "./modules/volumes"
  ZONE			= var.ZONE
  RESOURCE_GROUP = var.RESOURCE_GROUP
  HOSTNAME		= var.HOSTNAME
  VOL1			= local.VOL1
  VOL2			= local.VOL2
}


module "vsi" {
  source		= "./modules/vsi"
  depends_on	= [ module.volumes ]
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  HOSTNAME		= var.HOSTNAME
  PROFILE		= var.PROFILE
  IMAGE			= var.IMAGE
  SSH_KEYS		= var.SSH_KEYS
  VOLUMES_LIST	= module.volumes.volumes_list
  SAP_SID		= var.SAP_SID
}

module "ansible-exec-schematics-ci" {
  source  = "./modules/ansible-exec"
  depends_on	= [ module.vsi, local_file.tf_ansible_vars_generated_file  ]
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  IP = var.SAP_CI_HOST
  PLAYBOOK = "sapnwhdb-ci.yml"
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
  
}

module "ansible-exec-schematics" {
  source  = "./modules/ansible-exec"
  depends_on	= [ module.ansible-exec-schematics-ci, module.vsi, local_file.tf_ansible_vars_generated_file  ]
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  IP			= module.vsi.PRIVATE-IP
  PLAYBOOK = "sapnwhdb-aas.yml"
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
  
}

module "ansible-exec-ci" {
  source = "./modules/ansible-exec-ci/cli"
  depends_on = [ module.vsi, local_file.tf_ansible_vars_generated_file ]
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 1 : 0)
  IP = var.SAP_CI_HOST
}

module "ansible-exec" {
  source = "./modules/ansible-exec/cli"
  depends_on = [ module.vsi, module.ansible-exec-ci, local_file.tf_ansible_vars_generated_file ]
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 1 : 0)
  IP = module.vsi.PRIVATE-IP
  sap_main_password = var.SAP_MAIN_PASSWORD
}
