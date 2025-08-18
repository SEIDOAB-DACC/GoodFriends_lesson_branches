#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-cli-update.sh

#exec example
#./az-cli-update.sh ../az-resource-params/data-access

#NOTE:
#Get all access parameters
AzureCliContainer=$(./az-access.sh $1 docker-azure-container)

#start the docker container
printf "\nStopping and removing any already running $AzureCliContainer container\n"
docker stop $AzureCliContainer 2> /dev/null
docker rm $AzureCliContainer 2> /dev/null

#get the latest update of azure cli
printf "\npulling the latest update of azure cli\n"
docker pull mcr.microsoft.com/azure-cli:latest

printf "\nrun $AzureCliContainer container\n"
docker run -d --name $AzureCliContainer -p 2222:22 -p 8080:8080 mcr.microsoft.com/azure-cli:latest sleep infinity
