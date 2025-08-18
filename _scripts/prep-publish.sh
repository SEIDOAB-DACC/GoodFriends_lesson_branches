#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./publish.sh

#exec example
#./prep-publish.sh AppWebApi

if [[ -z "$1" ]]; then
    printf "\nMissing parameter:\n  ./prep-publish.sh AppWebApi\n"
    exit 1
fi


ApplicationToPublish=$1


SettingsFile="../AppWebApi/appsettings.json"
ApplicationSettingsFile=$(realpath "$SettingsFile")
AzureSettings=$(cat $ApplicationSettingsFile| grep -o '"'"AzureSettings"'": "[^"]*' | grep -o '[^"]*$')

PWDIR=$(pwd)
echo $PWDIR
cd ./azure/cli-bash
    
#Step1: Set the Azure Keyvault access parameters as operating system environment variables.
printf "\n\nSetting the azure key vault access as environent variables"
export AZURE_TENANT_ID=$(./az-access.sh $AzureSettings tenantId)
export AZURE_KeyVaultUri=$(./az-access.sh $AzureSettings kvUri)
export AZURE_KeyVaultSecret=$(./az-access.sh $AzureSettings kvSecret)

export AZURE_CLIENT_ID=$(./az-access-secrets.sh $AzureSettings app appId)
export AZURE_CLIENT_SECRET=$(./az-access-secrets.sh $AzureSettings app password)
cd $PWDIR

#verify environment variables
echo "AZURE_TENANT_ID=" $AZURE_TENANT_ID
echo "AZURE_KeyVaultUri=" $AZURE_KeyVaultUri
echo "AZURE_KeyVaultSecret=" $AZURE_KeyVaultSecret
echo "AZURE_CLIENT_ID=" $AZURE_CLIENT_ID
echo "AZURE_CLIENT_SECRET=" $AZURE_CLIENT_SECRET

#Step2: Default data user must be gstusr in production
printf "\n\nset DefaultDataUser to "gstusr" in appsettings.json...\n"
sed -i '' 's/"DefaultDataUser":[[:space:]]*"[^"]*"/"DefaultDataUser": "gstusr"/g' $ApplicationSettingsFile
sed -i '' 's/"SecretStorage":[[:space:]]*"[^"]*"/"SecretStorage": "AzureKeyVault"/g' $ApplicationSettingsFile

#Step3: Generate the release files
printf "\n\nPublish the webapi...\n"
# #remove any previous publish
rm -rf ../$ApplicationToPublish/publish

PWDIR=$(pwd)
echo $PWDIR
cd ../$ApplicationToPublish
dotnet publish --configuration Release --output ./publish


#Step4: Run the application from the folder containing the release files.
printf "\n\nEnsure any previous instances are stopped...\n"
lsof -ti tcp:5001 | xargs kill 

#Step5: Run the application from the folder containing the release files.
printf "\n\nRun the webapi from the published directory...\n"
cd ./publish

export ASPNETCORE_URLS="https://localhost:5001"
exec ./$ApplicationToPublish

cd $PWDIR