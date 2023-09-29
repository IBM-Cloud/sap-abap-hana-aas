# Automation script for SAP Netweaver on HANA DB additional application server installation using Terraform and Ansible integration


## Description
This solution will perform automated deployment of **SAP Netweaver on HANA DB additional application server** on an existing system.

It contains:  
- Terraform scripts for deploying a VSI in an EXISTNG VPC with Subnet and Security Group configs. The automation has support for the following versions: Terraform >= 1.3.6 and IBM Cloud provider for Terraform >= 1.41.1.  Note: The deployment was tested with Terraform 1.3.6
- Ansible scripts to install and configure a SAP Netweaver additional application server.
Please note that Ansible is started by Terraform and must be available on the same host.


IBM Cloud Activity Tracker service collects and stores audit records for API calls made to resources that run in the IBM Cloud. It can be used to monitor the activity of your IBM Cloud account, investigate abnormal activity and critical actions, and comply with regulatory audit requirements. In addition, you can be alerted on actions as they happen. For more information, see [IBM Cloud Activity Tracker](https://cloud.ibm.com/docs/activity-tracker?topic=activity-tracker-getting-started#gs_ov).

In order to track the events specific to the resources deployed by this solution, the IBM Cloud Activity Tracker to be used should be specified. In case there is no IBM Cloud Activity Tracker instance available in the same region as the IBM Cloud resources to be deployed, the automation will create a new one, based on the provided data.
Note: If you choose the automation to create a new activity plan at the same time with the deployment of the SAP solution and, later, you want to remove the IBM Cloud resources specific to the SAP solution, by using the automation, the activity planner will be removed as well.

The available pricing plans for an IBM Cloud Activity Tracker instance can be found [here](https://cloud.ibm.com/docs/activity-tracker?topic=activity-tracker-service_plan#service_plan).


## Contents:

- [1.1 Installation media](#11-installation-media)
- [1.2 VSI Configuration](#12-vsi-configuration)
- [1.3 VPC Configuration](#13-vpc-configuration)
- [1.4 Files description and structure](#14-files-description-and-structure)
- [1.5 General input variabiles](#15-general-input-variables)
- [2.1 Executing the deployment of **SAP Netweaver on HANA DB additional application server** in GUI (Schematics)](#21-executing-the-deployment-of-sap-netweaver-on-hana-db-additional-application-server-in-gui-schematics)
- [2.2 Executing the deployment of **SAP Netweaver on HANA DB additional application server** in CLI](#22-executing-the-deployment-of-sap-netweaver-on-hana-db-additional-application-server-in-cli)
- [3.1 Related links](#31-related-links)



## 1.1 Installation media
SAP Netweaver installation media used for this deployment is the default one for **SAP Netweaver 7.5** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

## 1.2 VSI Configuration
The VSI OS images that are supported for this solution are the following:

For Netweaver additional application server
- ibm-redhat-8-4-amd64-sap-applications-2
- ibm-redhat-8-6-amd64-sap-applications-2
- ibm-sles-15-3-amd64-sap-applications-2
- ibm-sles-15-4-amd64-sap-applications-4

Note: Please use the same OS image as used for the central instance of the SAP system. Using other OS release for the application server is not supported.

The VSIs should have least two SSH keys configured to access as root user and the following storage volumes created for SAP APP VSI:

SAP Netweaver AAS VSI Disks:
- 1x 40 GB disk with 10 IOPS / GB - SWAP
- 1 x 64 GB disk with 10 IOPS / GB - DATA

## 1.3 VPC Configuration

The Security Rules are the following:
- Allow all traffic in the Security group
- Allow all outbound traffic
- Allow inbound DNS traffic (UDP port 53)
- Allow inbound SSH traffic (TCP port 22)
- Option to Allow inbound TCP traffic with a custom port or a range of ports.

## 1.4 Files description and structure

 - `modules` - directory containing the terraform modules
 - `input.auto.tfvars` - contains the variables that will need to be edited by the user to customize the solution
 - `integration.tf` - contains the integration code that brings the SAP variabiles from Terraform to Ansible.
 - `main.tf` - contains the configuration of the VSI for SAP single tier deployment.
 - `provider.tf` - contains the IBM Cloud Provider data in order to run `terraform init` command.
 - `variables.tf` - contains variables for the VPC and VSI
 - `versions.tf` - contains the minimum required versions for terraform and IBM Cloud provider.
 - `output.tf` - contains the code for the information to be displayed after the VSI is created (Hostname, Private IP, Public IP,Activity Tracker Name)

## 1.5 General Input variables

**VSI input parameters:**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value).
PRIVATE_SSH_KEY | Required only for Schematics Deployments - Input your id_rsa private key pair content in OpenSSH format (Sensitive* value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
ID_RSA_FILE_PATH | The file path for PRIVATE_SSH_KEY will be automatically generated by default. If it is changed, it must contain the relative path from git repo folders.<br /> Default value: "ansible/id_rsa".
BASTION_FLOATING_IP | Required only for Schematics Deployments - The FLOATING IP from the Bastion Server.
SSH_KEYS | List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH UUIDs from IBM Cloud):<br /> [ "r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a" , "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e" ]
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Review supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
ZONE | The cloud zone where to deploy the solution. <br /> Sample value: eu-de-2.
VPC | The name of an EXISTING VPC. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs).
SUBNET | The name of an EXISTING Subnet. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets).
SECURITY_GROUP | The name of an EXISTING Security group. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups).
RESOURCE_GROUP | The name of an EXISTING Resource Group for VSIs and Volumes resources. <br /> Default value: "Default". The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
HOSTNAME | The Hostname for the VSI. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
PROFILE | The profile used for the VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles).<br> For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211)
IMAGE | The OS image used for the VSI. A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images)
VOL1 | Volume 1 Size - The size for the disks in GB that are to be attached to the VSI and used by SAP.
VOL2 | Volume 2 Size - The size for the disks in GB that are to be attached to the VSI and used by SAP.

**Activity Tracker input parameters:**

Parameter | Description
----------|------------
ATR_NAME | The name of the Activity Tracker instance to be created or the name of an existent Activity Tracker instance, in the same region chosen for SAP system deployment.
ATR_PROVISION | Enables (ATR_PROVISION=true) or not (ATR_PROVISION=false) the provisioning of a new Activity Tracker instance. <br /> Default value: true
ATR_PLAN | Mandatory only if ATR_PROVISION is set to true.  The list of service plan is available [here](https://cloud.ibm.com/docs/activity-tracker?topic=activity-tracker-service_plan#service_plan). <br /> Default value: "lite"
ATR_TAGS | Optional parameter. A list of user tags associated with the activity tracker instance.


**SAP input parameters:**

Parameter | Description | Requirements
----------|-------------|-------------
SAP_SID | The SAP system ID <SAPSID> identifies the entire SAP system | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>
SAP_CI_HOST | IP address of the existing SAP Central Instance|
SAP_CI_HOSTNAME | The hostname of the existing SAP Central Instance|
SAP_CI_INSTANCE_NUMBER | Technical identifier for internal processes of the Central Instance| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
SAP_ASCS_INSTANCE_NUMBER | Technical identifier for internal processes of ASCS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
HDB_INSTANCE_NUMBER | The instance number of the SAP HANA database server|
SAP_AAS_INSTANCE_NUMBER | Technical identifier for internal processes of the additional application server| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
KIT_SAPCAR_FILE  | Path to sapcar binary | As downloaded from SAP Support Portal
KIT_SWPM_FILE | Path to SWPM archive (SAR) | As downloaded from SAP Support Portal
KIT_SAPHOSTAGENT_FILE | Path to SAP Host Agent archive (SAR) | As downloaded from SAP Support Portal
KIT_HDBCLIENT_FILE | Path to HANA DB client archive (SAR) | As downloaded from SAP Support Portal

**Obs***: <br />

- The password for the SAP system will be asked interactively during terraform plan step and will not be available after the deployment.

Parameter | Description | Requirements
----------|-------------|-------------
SAP_MAIN_PASSWORD | Common password for all users that are created during the installation (See Obs*). | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li></ul>

- Sensitive - The variable value is not displayed in your Schematics logs and it is hidden in the input field, also is not displayed in your tf files details after terrafrorm plan&apply commands for CLI Deployments<br />
- The following parameters should have the same values as the ones set for the BASTION server: REGION, ZONE, VPC, SUBNET, SECURITY_GROUP.
- For any manual change in the terraform code, you have to make sure that you use a certified image based on the SAP NOTE: 2927211.

## 2.1 Executing the deployment of **SAP Netweaver on HANA DB additional application server** in GUI (Schematics)

### IBM Cloud API Key
The IBM Cloud API Key should be provided as input value of type sensitive for "IBMCLOUD_API_KEY" variable, in `IBM Schematics -> Workspaces -> <Workspace name> -> Settings` menu.
The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys).

### Input parameters

The following parameters can be set in the Schematics workspace: VPC, Subnet, Security group, Resource group, Hostname, Profile, Image, SSH Keys and your SAP system configuration variables. These are described in [General input variables Section](#15-general-input-variables) section.

Beside [General input variables Section](#15-general-input-variables), the below ones, in IBM Schematics have specific description and GUI input options:

**VSI input parameters:**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value).
PRIVATE_SSH_KEY | * Required only for Schematics Deployments - Input your id_rsa private key pair content in OpenSSH format (Sensitive* value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
ID_RSA_FILE_PATH | The file path for PRIVATE_SSH_KEY will be automatically generated by default. If it is changed, it must contain the relative path from git repo folders.<br /> Default value: "ansible/id_rsa".
BASTION_FLOATING_IP | * Required only for Schematics Deployments - The FLOATING IP from the Bastion Server.


### Steps to follow:

1.  Make sure that you have the [required IBM Cloud IAM
    permissions](https://cloud.ibm.com/docs/vpc?topic=vpc-managing-user-permissions-for-vpc-resources) to
    create and work with VPC infrastructure and you are [assigned the
    correct
    permissions](https://cloud.ibm.com/docs/schematics?topic=schematics-access) to
    create the workspace in Schematics and deploy resources.
2.  [Generate an SSH
    key](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys).
    The SSH key is required to access the provisioned VPC virtual server
    instances via the bastion host. After you have created your SSH key,
    make sure to [upload this SSH key to your IBM Cloud
    account](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-managing-ssh-keys#managing-ssh-keys-with-ibm-cloud-console) in
    the VPC region and resource group where you want to deploy the SAP solution
3.  Create the Schematics workspace:
    1.  From the IBM Cloud menu
    select [Schematics](https://cloud.ibm.com/schematics/overview).
       - Click Create a workspace.
       - Enter a name for your workspace.
       - Click Create to create your workspace.
    2.  On the workspace **Settings** page, enter the URL of this solution in the Schematics examples Github repository.
     - Select the latest Terraform version.
     - Click **Save template information**.
     - In the **Input variables** section, review the default input variables and provide alternatives if desired.
    - Click **Save changes**.

4.  From the workspace **Settings** page, click **Generate plan** 
5.  Click **View log** to review the log files of your Terraform
    execution plan.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the log file to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

The output of the Schematics Apply Plan will list the private IP address of the VSI host,hostname, and the Activity Tracker Name.


## 2.2 Executing the deployment of **SAP Netweaver on HANA DB additional application server** in CLI

### IBM Cloud API Key
For the script configuration add your IBM Cloud API Key in terraform planning phase command 'terraform plan --out plan1'.
You can create an API Key [here](https://cloud.ibm.com/iam/apikeys).
 
### Input parameter file
The solution is configured by editing your variables in the file `input.auto.tfvars`
Edit your VPC, Subnet, Security group, Hostnames, Profile, Image, SSH Keys and starting with minimal recommended disk sizes like so:

**VSI input parameters**

```shell
##########################################################
# General & Default VPC variables for CLI deployment
##########################################################

REGION = "eu-de"
# Region for the VSI. Supported regions: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Edit the variable value with your deployment Region.
# Example: REGION = "eu-de"

ZONE = "eu-de-1"
# Availability zone for VSI. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Edit the variable value with your deployment Zone.
# Example: ZONE = "eu-de-1"

VPC = "icp4sap"
# EXISTING VPC, previously created by the user in the same region as the VSI. The list of available VPCs: https://cloud.ibm.com/vpc-ext/network/vpcs
# Example: VPC = "ic4sap"

SECURITY_GROUP = "ic4sap-securitygroup"
# EXISTING Security group, previously created by the user in the same VPC. The list of available Security Groups: https://cloud.ibm.com/vpc-ext/network/securityGroups
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = "Default"
# EXISTING Resource group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SUBNET = "ic4sap-subnet"
# EXISTING Subnet in the same region and zone as the VSI, previously created by the user. The list of available Subnets: https://cloud.ibm.com/vpc-ext/network/subnets
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]
# List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. The SSH Keys should be created for the same region as the VSI. The list of available SSH Keys UUIDs: https://cloud.ibm.com/vpc-ext/compute/sshKeys
# Example: SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]

ID_RSA_FILE_PATH = "ansible/id_rsa"
# Input your existing id_rsa private key file path in OpenSSH format with 0600 permissions.
# This private key it is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
# It must contain the relative or absoute path from your Bastion.
# Examples: "ansible/id_rsa_sap_abap_hana_aas" , "~/.ssh/id_rsa_sap_abap_hana_aas" , "/root/.ssh/id_rsa".


##########################################################
# VSI variables:
##########################################################

HOSTNAME = "sapnwapp"
#The Hostname for the VSI. The hostname must have up to 13 characters as required by SAP.
#For more information on rules regarding hostnames for SAP systems, check SAP Note 611361: Hostnames of SAP ABAP Platform servers
# Example: HOSTNAME = "sapnwapp"

PROFILE = "bx2-4x16"
# The profile used for the VSI. Supported profiles for VSI: bx2-4x16. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

IMAGE = "ibm-redhat-8-6-amd64-sap-applications-2"
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
```

**Activity Tracker input parameters**

Edit your IBM Cloud Activity Tracker input variables below:

```shell
##########################################################
# Activity Tracker variables:
##########################################################

ATR_PROVISION = "true"
# Enables (ATR_PROVISION=true) or not (ATR_PROVISION=false) the provisioning of a new Activity Tracker instance. Default value: true
# Example to create Activity Tracker instance: ATR_PROVISION=true
# Example to use existing Activity Tracker instance : ATR_PROVISION=false

ATR_NAME = "Activity-Tracker-SAP-eu-de"
# The name of the Activity Tracker instance to be created or the name of an existent Activity Tracker instance, in the same region chosen for SAP system deployment.
# Example: ATR_NAME="Activity-Tracker-SAP-eu-de"

ATR_TAGS = [""]
# Optional parameter. A list of user tags associated with the activity tracker instance.
# Example: ATR_TAGS = ["activity-tracker-cos"]

ATR_PLAN = "lite"
# Mandatory only if ATR_PROVISION is set to true. The list of service plans - https://cloud.ibm.com/docs/activity-tracker?topic=activity-tracker-service_plan#service_plan
# Default value: "lite"
# Example: ATR_PLAN = "7-day"


```

Edit your SAP system configuration variables that will be passed to the ansible automated deployment:

```shell

##########################################################
# SAP system configuration
##########################################################

SAP_SID	= "NWD"
#The SAP system ID identifies the entire SAP system

SAP_CI_HOST = ""
#IP address of the existing SAP Central Instance

SAP_CI_HOSTNAME = "" 
#The hostname of the existing SAP Central Instance

SAP_CI_INSTANCE_NUMBER = "00"
#Technical identifier for internal processes of the Central Instance

SAP_ASCS_INSTANCE_NUMBER = "01"
#Technical identifier for internal processes of ASCS

HDB_INSTANCE_NUMBER = "00"
# The instance number of the SAP HANA database server

SAP_AAS_INSTANCE_NUMBER = "00"
#Technical identifier for internal processes of the additional application server

##########################################################
# Kit Paths
##########################################################

KIT_SAPCAR_FILE = "/storage/NW75HDB/SAPCAR_1010-70006178.EXE"
KIT_SWPM_FILE =  "/storage/NW75HDB/SWPM10SP31_7-20009701.SAR"
KIT_SAPHOSTAGENT_FILE = "/storage/NW75HDB/SAPHOSTAGENT51_51-20009394.SAR"
KIT_HDBCLIENT_FILE = "/storage/NW75HDB/IMDB_CLIENT20_009_28-80002082.SAR"
```

## Steps to reproduce:

For initializing terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan --out plan1
# you will be asked for the following sensitive variables: 'IBMCLOUD_API_KEY'  and  'SAP_MAIN_PASSWORD'.
```

For apply phase:

```shell
terraform apply "plan1"
```

For destroy:

```shell
terraform destroy
# you will be asked for the following sensitive variables as a destroy confirmation phase:
'IBMCLOUD_API_KEY'  and  'SAP_MAIN_PASSWORD'.
```

Note: The terraform destroy command will remove also the Activity Tracker instance, if it was provisioned at the same time with the SAP solution (when the parameter ATR_PROVISION was set to true during the deployment of the SAP solution).


### 3.1 Related links:

- [How to create a BASTION/STORAGE VSI for SAP in IBM Schematics](https://github.com/IBM-Cloud/sap-bastion-setup)
- [Securely Access Remote Instances with a Bastion Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-bastion-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)
- [IBM Cloud Activity Tracker](https://cloud.ibm.com/docs/activity-tracker?topic=activity-tracker-getting-started#gs_ov)
