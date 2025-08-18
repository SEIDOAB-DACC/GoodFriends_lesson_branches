#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-logout.sh

#Logout from your azure account

#To execute:
#./az-logout.sh ../az-resource-params/data-access

#Check inital parameters
if [ "$1" == "" ]
then
    printf "\n\nParameters error\n"
    exit 1
fi

#Get all access parameters
AzureCliContainer=$(./az-access.sh $1 docker-azure-container)

if [ "$AzureCliContainer" == "" ]
then
    printf "\n\nAzure access parameters error\n"
    exit 1
fi

printf "\nLogging out from Azure...\n"
docker exec -it $AzureCliContainer az logout

printf "\nConfirming that you are logged out from Azure\n"
docker exec -it $AzureCliContainer az account show

