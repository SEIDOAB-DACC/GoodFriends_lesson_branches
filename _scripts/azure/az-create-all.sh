#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-create-all.sh

#Complete workflow that creates all necessary Azure resources

#To execute:
# ./az-create-all.sh ./az-resource-params/data-access ../../Configuration/Configuration.csproj

# Exit immediately if any command fails
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

printf "\nStarting the Azure resource creation workflow for $AzureProjectSettings\n\n"

./az-login.sh $AzureProjectSettings

#create resource group
./az-rg-create.sh $AzureProjectSettings

#create keyvault
./az-kv-create.sh $AzureProjectSettings

#Create a WebService plan and application 
./az-app-create.sh $AzureProjectSettings

#Testing by creating a simple secret
./az-kv-sec-simple.sh $AzureProjectSettings

#Testing by moving user secrets default
./az-kv-sec-copy.sh $AzureProjectSettings $ApplicationProjectFile

#Create a sql server
./az-sqlserver-create.sh $AzureProjectSettings

#Create an sql server database - after this you can connect with Azure Data Studio using the resulting connection string 
./az-sqlserver-db-create.sh $AzureProjectSettings

#create keyvault app with service principle role to read secrets
./az-kv-user-create.sh $AzureProjectSettings

#Set the environment variables to access the created azure keyvault above
./az-app-set-env.sh $AzureProjectSettings

SqlDbCStringFile=$(./az-access-secrets.sh $AzureProjectSettings sql cstringfile)

printf "\nSql Server Connection string is:\n"
cat $SqlDbCStringFile

cd $PWD

#only come here if all previous commands were successful
printf "\n\nSuccess! Workflow completed successfully!\n"