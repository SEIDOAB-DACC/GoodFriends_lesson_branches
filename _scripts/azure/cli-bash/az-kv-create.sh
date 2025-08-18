#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-kv-create.sh

#Creates a new Azure Key Vault

#To execute:
#./az-kv-create.sh ../az-resource-params/data-access

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
AzureResourceGroup=$(./az-access.sh $1 resourceGroup)
AzureKeyVaultName=$(./az-access.sh $1 kvName)

#create the key vault
printf "\n\nCreating key vault $AzureKeyVaultName...\n" 
docker exec -it $AzureCliContainer az keyvault create --name $AzureKeyVaultName --resource-group $AzureResourceGroup

printf "\n\nAssigning owner credential to $AzureKeyVaultName...\n" 
#1. Get principal id from signed in user
PrincipalId=$(docker exec -it $AzureCliContainer az ad signed-in-user show | grep -o '"id": "[^"]*' | grep -o '[^"]*$')

#2. Define the Role, I'm using a Azure build in
Role="Key Vault Administrator"

#3. Get the scope of $AzureResourceGroup
RoleScope=$(docker exec -it $AzureCliContainer az group list --query "[?contains(name, '$AzureResourceGroup')].{id:id}" | grep -o '"id": "[^"]*' | grep -o '[^"]*$')

#assign the role and scope to the principal
docker exec -it $AzureCliContainer az role assignment create --assignee $PrincipalId --role "$Role" --scope "$RoleScope"

#only come here if all previous commands were successful
printf "\n\nSuccess! All commands completed successfully!\n"



#echo "$PrincipalId"
#echo "$RoleScope"
#echo "$Role"

#https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-cli
#Get principal id from signed in user

# az ad signed-in-user show --query id -o tsv

# #List all role assignments for the devops course
# az role assignment list --resource-group devops-course
# az role assignment list --resource-group devops-course --o table

# az role definition list --name "Key Vault Administrator"

# az group list --query "[].{Name:name,Location:location}" -o table
# az group list --query "[?contains(name, 'devops-course')].{Name:name,Location:location}" -o table
# az group list --query "[?contains(name, 'devops-course')].{name:name,id:id}"
# az group list --query "[?contains(name, 'devops-course')].{id:id}" -o tsv

# az role assignment create --assignee "89a1dc7f-dee0-409c-bb2d-97d30827e929" --role "Key Vault Administrator" --scope "/subscriptions/3109d275-849b-45b3-a493-a5631aafee6d/resourceGroups/devops-course"
