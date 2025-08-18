#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-kv-create-secret.sh

#Creates a simple text secret in an Azure Key Vault

#To execute:
#./az-kv-sec-simple.sh ../az-resource-params/data-access

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
AzureKeyVaultSecret=$(./az-access.sh $1 kvSecret)

SecretMessage="Super-secret-Hello-from-Seido"

#https://learn.microsoft.com/en-us/azure/key-vault/general/manage-with-cli2
#Secret creations
printf "\n\nCreating a test secret, $AzureKeyVaultSecret,  in vault $AzureKeyVaultName...\n"
docker exec -it $AzureCliContainer az keyvault secret set --vault-name "$AzureKeyVaultName" --name "$AzureKeyVaultSecret" --value "$SecretMessage"

#only come here if all previous commands were successful
printf "\n\nSuccess! All commands completed successfully!\n"