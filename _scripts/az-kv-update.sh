#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-kv-update.sh

ProjectFile="../Configuration/Configuration.csproj"
SettingsFile="../AppWebApi/appsettings.json"

ApplicationProjectFile=$(realpath "$ProjectFile")
ApplicationSettingsFile=$(realpath "$SettingsFile")

PWDIR=$(pwd)
cd ./azure/cli-bash

# Read the AzureSettings path from appsettings.json
printf "\nReading Azure settings from: $ApplicationSettingsFile\n"
AzureSettings=$(cat $ApplicationSettingsFile| grep -o '"'"AzureSettings"'": "[^"]*' | grep -o '[^"]*$')

./az-login.sh $AzureSettings

./az-kv-sec-copy.sh $AzureSettings $ApplicationProjectFile

printf "\nSet SecretStorage to 'AzureKeyVault' in appsettings.json...\n"
sed -i '' 's/"SecretStorage":[[:space:]]*"[^"]*"/"SecretStorage": "AzureKeyVault"/g' $ApplicationSettingsFile

printf "\nSuccess! Azure Key Vault update completed successfully!\n"

cd $PWDIR