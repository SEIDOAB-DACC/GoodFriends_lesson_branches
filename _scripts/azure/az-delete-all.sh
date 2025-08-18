#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-delete-all.sh

#Complete workflow that deletes all necessary Azure resources

#To execute:
#./az-delete-all.sh ./az-resource-params/data-access

# Exit immediately if any command fails
set -e

if [ -z "$1" ]; then
    printf "\nParameter error\n"
    exit 1
fi

AzureProjectSettings=$(realpath "$1")

PWD=$(pwd)
cd ./cli-bash

./az-login.sh $AzureProjectSettings

#remove the resource group and all assets in it
./az-rg-delete.sh $AzureProjectSettings

./az-logout.sh $AzureProjectSettings

cd $PWD

#only come here if all previous commands were successful
printf "\n\nSuccess! Workflow completed successfully!\n"