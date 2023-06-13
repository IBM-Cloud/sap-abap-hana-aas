#Infra VPC variables
REGION = "eu-de"
ZONE = "eu-de-2"
VPC = "ic4sap" # EXISTING Security group name
SECURITY_GROUP = "ic4sap-securitygroup" # EXISTING Security group name
SUBNET = "alint-de-subnet2" # EXISTING Subnet name
HOSTNAME = "sapnwapp1065"
PROFILE = "bx2-4x16"
IMAGE = "ibm-redhat-8-6-amd64-sap-applications-2"
RESOURCE_GROUP = "wes-automation" # EXISTING Resource Group for VSI and volumes
SSH_KEYS                = [ "r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a" , "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e" , "r010-771e15dd-8081-4cca-8844-445a40e6a3b3" , "r010-09325e15-15be-474e-9b3b-21827b260717" , "r010-5cfdb578-fc66-4bf7-967e-f5b4a8d03b89" , "r010-7b85d127-7493-4911-bdb7-61bf40d3c7d4" , "r010-d941534b-1d30-474e-9494-c26a88d4cda3" , "r010-e372fc6f-4aef-4bdf-ade6-c4b7c1ad61ca" ]

##SAP system configuration
sap_sid	= "NWD"
sap_ci_host = "10.243.64.28"
sap_ci_hostname = "sapnwci1065" 
sap_ci_instance_number = "00"
sap_ascs_instance_number = "01"
hdb_instance_number = "00"
sap_aas_instance_number = "00"

#Kits paths
kit_sapcar_file = "/storage/NW75HDB/SAPCAR_1010-70006178.EXE"
kit_swpm_file =  "/storage/NW75HDB/SWPM10SP31_7-20009701.SAR"
kit_saphotagent_file = "/storage/NW75HDB/SAPHOSTAGENT51_51-20009394.SAR"
kit_hdbclient_file = "/storage/NW75HDB/IMDB_CLIENT20_009_28-80002082.SAR"
