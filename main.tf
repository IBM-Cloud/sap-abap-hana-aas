module "pre-init-schematics" {
  source  = "./modules/pre-init"
  count = (var.private_ssh_key == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  private_ssh_key = var.private_ssh_key
}

module "pre-init-cli" {
  source  = "./modules/pre-init/cli"
  count = (var.private_ssh_key == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 1 : 0)
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
}

module "precheck-ssh-exec" {
  source  = "./modules/precheck-ssh-exec"
  count = (var.private_ssh_key == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  depends_on	= [ module.pre-init-schematics ]
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  private_ssh_key = var.private_ssh_key
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
  VOL1			= var.VOL1
  VOL2			= var.VOL2
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
  SAP_SID		= var.sap_sid
}

module "ansible-exec-schematics-ci" {
  source  = "./modules/ansible-exec"
  depends_on	= [ module.vsi, local_file.tf_ansible_vars_generated_file  ]
  count = (var.private_ssh_key == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  IP			= var.sap_ci_host
  PLAYBOOK = "sapnwhdb-ci.yml"
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  private_ssh_key = var.private_ssh_key
  
}

module "ansible-exec-schematics" {
  source  = "./modules/ansible-exec"
  depends_on	= [ module.ansible-exec-schematics-ci, module.vsi, local_file.tf_ansible_vars_generated_file  ]
  count = (var.private_ssh_key == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  IP			= module.vsi.PRIVATE-IP
  PLAYBOOK = "sapnwhdb-aas.yml"
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  private_ssh_key = var.private_ssh_key
  
}

module "ansible-exec-ci" {
  source		= "./modules/ansible-exec-ci/cli"
  depends_on	= [ module.vsi, local_file.tf_ansible_vars_generated_file ]
  count = (var.private_ssh_key == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 1 : 0)
  IP			= var.sap_ci_host
}

module "ansible-exec" {
  source		= "./modules/ansible-exec/cli"
  depends_on	= [ module.vsi, module.ansible-exec-ci, local_file.tf_ansible_vars_generated_file ]
  count = (var.private_ssh_key == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 1 : 0)
  IP			= module.vsi.PRIVATE-IP
  sap_main_password = var.sap_main_password
}
