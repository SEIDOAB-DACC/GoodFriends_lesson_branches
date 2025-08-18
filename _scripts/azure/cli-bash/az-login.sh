#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-login.sh

#Login to your azure account according to your tentantid

#To execute:
#./az-login.sh ../az-resource-params/data-access

#Check inital parameters
if [ "$1" == "" ]
then
    printf "\n\nParameters error\n"
    exit 1
fi

#Get all access parameters
AzureCliContainer=$(./az-access.sh $1 docker-azure-container)
AzureHomeTenantId=$(./az-access.sh $1 tenantId)

if [ "$AzureCliContainer" == "" ] || [ "$AzureHomeTenantId" == "" ] 
then
    printf "\n\nAzure access parameters error\n"
    exit 1
fi

#start the container $AzureCliContainer in Docker Desktop
docker ps -a | grep "$AzureCliContainer" | awk '{print $1}' |  xargs docker start

#login to azure, if not already
#test if logged in
LoggedInTenant=$(docker exec -it $AzureCliContainer az account show | grep -o '"homeTenantId": "[^"]*' | grep -o '[^"]*$')
if [[ $LoggedInTenant != $AzureHomeTenantId ]]; then

    printf "\nNot logged in\n"
    docker exec -it $AzureCliContainer az logout

    printf "\nLogging in to azure as $AzureHomeTenantId...\n"
    docker exec -it $AzureCliContainer az login --tenant $AzureHomeTenantId
else 

    printf "\nLogged in as $LoggedInTenant\n\n"
fi

docker exec -it $AzureCliContainer az account show
printf "\nLogged in as $LoggedInTenant\n\n"

#only come here if all previous commands were successful
printf "\n\nSuccess! All commands completed successfully!\n"

#To generate GUID
#uuidgen
