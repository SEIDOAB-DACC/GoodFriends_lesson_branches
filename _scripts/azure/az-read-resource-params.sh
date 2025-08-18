#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-read-resource-params.sh

# Reads all parameters of azure assets 
# Exit immediately if any command fails

#To execute:
# ./az-read-resource-params.sh ./az-resource-params/data-access ../../Configuration/Configuration.csproj

set -e

#Check inital parameters
if [ -z "$1" ] || [ -z "$2" ]; then
    printf "\nParameter error\n"
    exit 1
fi

AzureProjectSettings=$(realpath "$1")
ApplicationProjectFile=$(realpath "$2")

PWD=$(pwd)
cd ./cli-bash

printf "\nReading all the Azure parameters of $AzureProjectSettings\n\n"

./az-access.sh $AzureProjectSettings docker-azure-container
./az-access.sh $AzureProjectSettings tenantId
./az-access.sh $AzureProjectSettings resourceGroup
./az-access.sh $AzureProjectSettings kvUri
./az-access.sh $AzureProjectSettings kvName
./az-access.sh $AzureProjectSettings kvSecret
./az-access.sh $AzureProjectSettings kvReadClient
./az-access.sh $AzureProjectSettings sqlServer
./az-access.sh $AzureProjectSettings sqlDb
./az-access.sh $AzureProjectSettings appservicePlanName
./az-access.sh $AzureProjectSettings appserviceName
./az-access.sh $AzureProjectSettings path
./az-access.sh $AzureProjectSettings file
./az-access.sh $AzureProjectSettings template
./az-access.sh $AzureProjectSettings fname

./az-access-secrets.sh $AzureProjectSettings app appId
./az-access-secrets.sh $AzureProjectSettings app displayName
./az-access-secrets.sh $AzureProjectSettings app password
./az-access-secrets.sh $AzureProjectSettings app path
./az-access-secrets.sh $AzureProjectSettings app file
./az-access-secrets.sh $AzureProjectSettings app fname

./az-access-secrets.sh $AzureProjectSettings sql sqlRootUser
./az-access-secrets.sh $AzureProjectSettings sql sqlRootPassword
./az-access-secrets.sh $AzureProjectSettings sql path
./az-access-secrets.sh $AzureProjectSettings sql file
./az-access-secrets.sh $AzureProjectSettings sql fname
./az-access-secrets.sh $AzureProjectSettings sql cstring
./az-access-secrets.sh $AzureProjectSettings sql cstringfile

./az-access-secrets.sh $AzureProjectSettings usrsec path $ApplicationProjectFile
./az-access-secrets.sh $AzureProjectSettings usrsec file $ApplicationProjectFile
./az-access-secrets.sh $AzureProjectSettings usrsec fname $ApplicationProjectFile
./az-access-secrets.sh $AzureProjectSettings usrsec file $ApplicationProjectFile
./az-access-secrets.sh $AzureProjectSettings usrsec path $ApplicationProjectFile
./az-access-secrets.sh $AzureProjectSettings usrsec fname $ApplicationProjectFile

cd $PWD

#only come here if all previous commands were successful
printf "\n\nSuccess! All commands completed successfully!\n\n"

