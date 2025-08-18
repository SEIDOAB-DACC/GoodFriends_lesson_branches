#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-sqlserver-create.sh

#Creates an Azure SqlServer

#To execute:
#./az-sqlserver-create.sh ../az-resource-params/data-access

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
ResourceGroup=$(./az-access.sh $1 resourceGroup)

SqlServerName=$(./az-access.sh $1 sqlServer)
SqlServerSa=$(./az-access-secrets.sh $1 sql sqlRootUser)
SqlServerSaPassword=$(./az-access-secrets.sh $1 sql sqlRootPassword)

#https://learn.microsoft.com/en-us/azure/azure-sql/database/scripts/create-and-configure-database-cli?view=azuresql
printf "\n\nCreating $SqlServerName in $ResourceGroup...\n"
docker exec $AzureCliContainer az sql server create --name $SqlServerName --resource-group $ResourceGroup\
 --location "swedencentral" --admin-user $SqlServerSa --admin-password $SqlServerSaPassword

#Setting up the firewall
./az-sqlserver-fw-open-myip.sh $1

#only come here if all previous commands were successful
printf "\n\nSuccess! All commands completed successfully!\n"