#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-rg-delete.sh

#Deletes the resource group and all the assets included
#Deletes all tenants created as Key Vault users

#To execute:
#./az-rg-delete.sh ../az-resource-params/data-access

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
ApplicationName=$(./az-access-secrets.sh $1 app displayName)

#remove the resource group
printf "\nRemoving resource group $AzureResourceGroup...\n"
docker exec $AzureCliContainer az group delete --name $AzureResourceGroup --yes

#remove application and therefore also the service principal
printf "\nRemoving application $ApplicationName...\n"
AppId=$(docker exec $AzureCliContainer az ad app list --display-name $ApplicationName | grep -o '"appId": "[^"]*' | grep -o '[^"]*$')
if [[ -nz "$AppId" ]]; then
    docker exec $AzureCliContainer az ad app delete --id $AppId
fi


#only come here if all previous commands were successful
printf "\n\nSuccess! All commands completed successfully!\n"