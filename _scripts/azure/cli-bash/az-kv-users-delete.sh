#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-kv-users-delete.sh

#Deletes all application tenant that can read the Azure Key Vault
#tenant are registered with Microsoft Entra

#To execute:
#./az-kv-users-delete.sh ../az-resource-params/data-access

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
AzureHomeTenantId=$(./az-access.sh $1 tenantId)

AzureResourceGroup=$(./az-access.sh $1 resourceGroup)
AzureKeyVaultName=$(./az-access.sh $1 kvName)
ApplicationName=$(./az-access.sh $1 kvReadClient)


# Get all service principal IDs for the given display name
SPS_JSON=$(docker exec $AzureCliContainer az ad sp list --display-name "$ApplicationName" --output json)

# Check if any service principals were found
if [ -z "$SPS_JSON" ]; then
    printf "\n\nNo service principals found with display name: $ApplicationName"
    exit 0
fi

# Delete each service principal
echo "Deleting service principals..."
echo "$SPS_JSON" | jq -r '.[].id' | while read -r sp_id; do
    if [ -n "$sp_id" ]; then
        echo "Deleting service principal: $sp_id"

        docker exec $AzureCliContainer az ad sp delete --id $sp_id
    fi
done

#only come here if all previous commands were successful
printf "\n\nSuccess! All commands completed successfully!\n"



