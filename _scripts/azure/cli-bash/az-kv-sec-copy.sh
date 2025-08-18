#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-kv-sec-copy.sh

#Copies user secrets into an Azure Key Vault

#To execute:
#./az-kv-sec-copy.sh ../az-resource-params/data-access ../../../Configuration/Configuration.csproj

# Exit immediately if any command fails
set -e

#Check inital parameters
if [ "$1" == "" ] || [ "$2" == "" ]
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

# Secrets unique to application,
# $2 could be "../WebApiTemplate_branches/Configuration/Configuration.csproj"
UserSecretFile=$(./az-access-secrets.sh $1 usrsec file $2)
UserSecretFileName=$(./az-access-secrets.sh $1 usrsec fname $2)

if [ "$2" == "" || "$UserSecretFile" == "" ] || [ "$UserSecretFileName" == "" ] 
then
    printf "\n\nAzure secrets parameters error\n"
    exit 1
fi

printf "\n\nKey vault access parameters\n"
printf "UserSecretFile=$UserSecretFile\n"
printf "AzureKeyVaultSecret=$AzureKeyVaultSecret\n"
printf "AzureHomeTenantId=$AzureHomeTenantId\n"
printf "AzureKeyVaultName=$AzureKeyVaultName\n\n"

#start the container $AzureCliContainer in Docker Desktop
printf "\n\nStart the container $AzureCliContainer...\n"
docker ps -a | grep "$AzureCliContainer" | awk '{print $1}' |  xargs docker start

#Create location for user secret in Azure cli container
printf "\n\nCreating folder $AzureKeyVaultSecret in container $AzureCliContainer...\n"
docker exec -it $AzureCliContainer rm -rf $AzureKeyVaultSecret 
docker exec -it $AzureCliContainer mkdir $AzureKeyVaultSecret 
docker exec -it $AzureCliContainer ls

#copy user secrets into Azure cli container at right location
printf "\n\nCopying $UserSecretFile to folder $AzureKeyVaultSecret...\n"
docker cp $UserSecretFile $AzureCliContainer:$AzureKeyVaultSecret

#create and copy the secret to azkv
printf "\n\nCopying $AzureKeyVaultSecret/$UserSecretFileName to secret $AzureKeyVaultSecret in keyvault $AzureKeyVaultName...\n"
docker exec -it $AzureCliContainer az keyvault secret set --name "$AzureKeyVaultSecret" --vault-name "$AzureKeyVaultName" --file "$AzureKeyVaultSecret/$UserSecretFileName"

#Cleanup
#rm location for user secret in Azure cli container
printf "\n\nRemoving folder $AzureKeyVaultSecret in container $AzureCliContainer...\n"
docker exec -it $AzureCliContainer rm -rf $AzureKeyVaultSecret 
docker exec -it $AzureCliContainer ls


#only come here if all previous commands were successful
printf "\n\nSuccess! All commands completed successfully!\n"