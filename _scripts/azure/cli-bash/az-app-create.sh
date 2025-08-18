#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-app-create.sh

#Creates an Azure App Service

#To execute:
#./az-app-create.sh ../az-resource-params/data-access

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
AppServicePlan=$(./az-access.sh $1 appservicePlanName)
AppService=$(./az-access.sh $1 appserviceName)

HomeTenantId=$(./az-access.sh $1 tenantId)
AzureKeyVaultUri=$(./az-access.sh $1 kvUri)
AzureKeyVaultSecret=$(./az-access.sh $1 kvSecret)

AzureClientId=$(./az-access-secrets.sh $1 app appId)
AzureClientSecret==$(./az-access-secrets.sh $1 app password)

#create the app service plan
#https://learn.microsoft.com/en-us/cli/azure/appservice/plan?view=azure-cli-latest#az-appservice-plan-create
printf "\n\nCreating app service plan $AppServicePlan...\n" 
docker exec $CliContainer az appservice plan create -g $ResourceGroup -n $AppServicePlan --sku F1


#create the app service plan
#https://learn.microsoft.com/en-us/cli/azure/appservice/plan?view=azure-cli-latest#az-appservice-plan-create
printf "\n\nCreating web app service $AppService using plan $AppServicePlan...\n" 
docker exec $CliContainer az webapp create -g $ResourceGroup -p $AppServicePlan -n $AppService


#only come here if all previous commands were successful
printf "\n\nSuccess! All commands completed successfully!\n"