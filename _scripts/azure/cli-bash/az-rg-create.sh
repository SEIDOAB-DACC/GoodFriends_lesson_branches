#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-kv-create.sh

#Creates a new Azure Resource Group

#To execute:
#./az-lrg-create.sh ../az-resource-params/data-access

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

#create the resource group
printf "\n\nCreating resource group $AzureResourceGroup...\n" 
docker exec -it $AzureCliContainer az group create --name $AzureResourceGroup --location swedencentral

#only come here if all previous commands were successful
printf "\n\nSuccess! All commands completed successfully!\n"