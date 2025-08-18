#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-kv-user-create.sh

#Creates an application tenant that can read the Azure Key Vault
#tenant is registered with Microsoft Entra

#To execute:
#./az-kv-user-create.sh ../az-resource-params/data-access

# Exit immediately if any command fails
set -e

#Check inital parameters
if [ "$1" == "" ]
then
    printf "\n\nParameters error\n"
    exit 1
fi

#Get all access parameters
AzureCliContainer=$(./az-access.sh $1 docker-azure-container)
AzureHomeTenantId=$(./az-access.sh $1 tenantId)

AzureResourceGroup=$(./az-access.sh $1 resourceGroup)
AzureKeyVaultName=$(./az-access.sh $1 kvName)
ApplicationName=$(./az-access.sh $1 kvReadClient)

ApplicationFile=$(./az-access-secrets.sh $1 app file)

#Setting role and rolescope to the resource
Role="Key Vault Secrets User"
RoleScope=$(docker exec -it $AzureCliContainer az group list --query "[?contains(name, '$AzureResourceGroup')].{id:id}" | grep -o '"id": "[^"]*' | grep -o '[^"]*$')

#Registering an application with Microsoft Entra ID
printf "\n\nRegistering application $ApplicationName with Microsoft Entra ID...\n"
docker exec -it $AzureCliContainer az ad sp create-for-rbac -n "$ApplicationName" --role "$Role" --scope "$RoleScope"\
 | awk 'BEGIN {print "{"} /{/{flag=1; next} /}/{flag=0} flag {print} END {print "}"}' \
  > "$ApplicationFile"

printf "\n\nAccess keys to $AzureKeyVaultName are stored in $ApplicationFile\n"


#only come here if all previous commands were successful
printf "\n\nSuccess! All commands completed successfully!\n"

# $ApplicationFile will look like below
# {
#   "appId": "41c490f8-9ec2-4e0c-a452-fd2c450fb00f",
#   "displayName": "$ApplicationName",
#   "password": "mpm8Q~qsAlkNYTNGhs-RV4v_JjzbB1Ml2m.3qaXQ",
#   "tenant": "1572fbad-267f-4fa0-82b2-2a5de30ac664"
# }

#az ad sp list --display-name "$ApplicationName" --output table
#az ad sp delete --id ae67b435-a8cd-4357-9f00-cce40a5a859c
#az ad app delete --id <appId>


