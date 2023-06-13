# Automation script for SAP Netweaver on HANA DB additional application server installation using Terraform and Ansible integration


## Description
This solution will perform automated deployment of **SAP Netweaver on HANA DB additional application server** on an existing system.

It contains:  
- Terraform scripts for deploying a VSI in an EXISTNG VPC with Subnet and Security Group configs.
- Ansible scripts to install and configure a SAP Netweaver additional application server.
Please note that Ansible is started by Terraform and must be available on the same host.

## Installation media
SAP Netweaver installation media used for this deployment is the default one for **SAP Netweaver 7.5** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

## VSI Configuration
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

## IBM Cloud API Key
Your IBM Cloud API Key will be asked interactively during terraform plan step.

## Input parameter file
The solution is configured by editing your variables in the file `input.auto.tfvars`
Edit your VPC, Subnet, Security group, Hostname, Profile, Image, SSH Keys like so:

```shell
# General VPC variables:
REGION			= "eu-de"
ZONE			= "eu-de-2"
VPC				= "ic4sap"                        # EXISTING Security group name
SECURITY_GROUP	= "ic4sap-securitygroup"      # EXISTING Security group name
RESOURCE_GROUP  = "wes-automation"
SUBNET			= "ic4sap-subnet"               # EXISTING Subnet name
SSH_KEYS                = [ "r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a" , "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e" ]

# SAP AAS VSI variables:
HOSTNAME = "sapnwapp"
PROFILE = "bx2-4x16"
IMAGE = "ibm-redhat-8-6-amd64-sap-applications-2"
```

Parameter | Description
----------|------------
REGION | The cloud region where to deploy the solution. The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc)
ZONE | The cloud zone where to deploy the solution
VPC | The name of the VPC. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SECURITYGROUP | The name of the Security Group. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups)
RESOURCE_GROUP | An EXISTING Resource Group for VSI and volumes. The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups)
SUBNET | The name of the Subnet. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets)
SSH_KEYS | List of SSH Keys IDs that are allowed to SSH as root to the VSI. Can contain one or more IDs.<br> The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys)
HOSTNAME | The Hostname for the VSI. The hostname must have up to 13 characters as required by SAP.<br> For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
PROFILE | The profile used for the VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles).<br> For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211)
IMAGE | The OS image used for the VSI. A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images)

Edit your SAP system configuration variables that will be passed to the ansible automated deployment:

```shell
#SAP system configuration
sap_sid	= "NWD"
sap_ci_host = "10.243.132.10"
sap_ci_hostname = "sapnwci" 
sap_ci_instance_number = "00"
sap_ascs_instance_number = "01"
sap_aas_instance_number = "00"

#Kits paths
kit_sapcar_file = "/storage/NW75HDB/SAPCAR_1010-70006178.EXE"
kit_swpm_file =  "/storage/NW75HDB/SWPM10SP31_7-20009701.SAR"
kit_saphotagent_file = "/storage/NW75HDB/SAPHOSTAGENT51_51-20009394.SAR"
kit_hdbclient_file = "/storage/NW75HDB/IMDB_CLIENT20_009_28-80002082.SAR"
```
**SAP input parameters:**

Parameter | Description | Requirements
----------|-------------|-------------
sap_sid | The SAP system ID <SAPSID> identifies the entire SAP system | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>
sap_ci_host | IP address of the existing SAP Central Instance|
sap_ci_hostname | The hostname of the existing SAP Central Instance|
sap_ci_instance_number | Technical identifier for internal processes of the Central Instance| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
sap_ascs_instance_number | Technical identifier for internal processes of ASCS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
sap_aas_instance_number | Technical identifier for internal processes of the additional application server| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
kit_sapcar_file  | Path to sapcar binary | As downloaded from SAP Support Portal
kit_swpm_file | Path to SWPM archive (SAR) | As downloaded from SAP Support Portal
kit_saphostagent_file | Path to SAP Host Agent archive (SAR) | As downloaded from SAP Support Portal
kit_hdbclient_file | Path to HANA DB client archive (SAR) | As downloaded from SAP Support Portal

**SAP Main Password**
The password for the SAP system will be asked interactively during terraform plan step and will not be available after the deployment.

Parameter | Description | Requirements
----------|-------------|-------------
sap_main_password | Common password for all users that are created during the installation | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li></ul>

**Obs***: <br />
- Sensitive - The variable value is not displayed in your tf files details after terrafrorm plan&apply commands.<br />
- The following variables should be the same like the bastion ones: REGION, ZONE, VPC, SUBNET, SECURITY_GROUP.

## VPC Configuration

The Security Rules are the following:
- Allow all traffic in the Security group
- Allow all outbound traffic
- Allow inbound DNS traffic (UDP port 53)
- Allow inbound SSH traffic (TCP port 22)
- Option to Allow inbound TCP traffic with a custom port or a range of ports.



## Files description and structure:
 - `modules` - directory containing the terraform modules
 - `input.auto.tfvars` - contains the variables that will need to be edited by the user to customize the solution
 - `integration.tf` - contains the integration code that brings the SAP variabiles from Terraform to Ansible.
 - `main.tf` - contains the configuration of the VSI for SAP single tier deployment.
 - `provider.tf` - contains the IBM Cloud Provider data in order to run `terraform init` command.
 - `variables.tf` - contains variables for the VPC and VSI
 - `versions.tf` - contains the minimum required versions for terraform and IBM Cloud provider.
 - `output.tf` - contains the code for the information to be displayed after the VSI is created (Hostname, Private IP, Public IP)

## Steps to reproduce:

For initializing terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan --out plan1
# you will be asked for the following sensitive variables: 'ibmcloud_api_key'  and  'sap_main_password'.
```

For apply phase:

```shell
terraform apply "plan1"
```

For destroy:

```shell
terraform destroy
# you will be asked for the following sensitive variables as a destroy confirmation phase:
'ibmcloud_api_key'  and  'sap_main_password'.
```


### Related links:

- [How to create a BASTION/STORAGE VSI for SAP in IBM Schematics](https://github.com/IBM-Cloud/sap-bastion-setup)
- [Securely Access Remote Instances with a Bastion Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-bastion-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)