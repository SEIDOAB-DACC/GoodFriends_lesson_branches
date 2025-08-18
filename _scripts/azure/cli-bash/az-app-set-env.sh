#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-app-set-env.sh

#Set the environment variables to allow the app to access the KeyVault

#To execute:
#./az-app-set-env.sh ../az-resource-params/data-access

# Exit immediately if any command fails
set -e

#Check inital parameters
if [ "$1" == "" ]
then
    printf "\n\nParameters error\n"
    exit 1
fi

#Get all access parameters
CliContainer=$(./az-access.sh $1 docker-azure-container)
ResourceGroup=$(./az-access.sh $1 resourceGroup)
AppService=$(./az-access.sh $1 appserviceName)

HomeTenantId=$(./az-access.sh $1 tenantId)
AzureKeyVaultUri=$(./az-access.sh $1 kvUri)
AzureKeyVaultSecret=$(./az-access.sh $1 kvSecret)

AzureClientId=$(./az-access-secrets.sh $1 app appId)
AzureClientSecret=$(./az-access-secrets.sh $1 app password)


#Setting anvironmental variables to access keyvault
#https://learn.microsoft.com/en-us/cli/azure/webapp/config/appsettings?view=azure-cli-latest#az-webapp-config-appsettings-set
printf "\n\nSetting environment variables on web app service $AppService to access keyvault $AzureKeyVaultUri...\n" 
docker exec $CliContainer az webapp config appsettings set -g $ResourceGroup -n $AppService --settings \
    AZURE_TENANT_ID=$HomeTenantId \
    AZURE_KeyVaultUri=$AzureKeyVaultUri \
    AZURE_KeyVaultSecret=$AzureKeyVaultSecret \
    AZURE_CLIENT_ID=$AzureClientId \
    AZURE_CLIENT_SECRET=$AzureClientSecret


#only come here if all previous commands were successful
printf "\n\nSuccess! All commands completed successfully!\n"