#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-access-secrets.sh

#Gets the Azure Access parameters from file in ../az-resource-params/az-access-secrets folder
#NOTE: null responses indicates error
#usage 
#./az-access-secrets {az-resource-params path} [app|sql|usrsec] [{json-key}|file|path|fname|cstring|cstringfile]

#Check inital parameters
if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ] 
then
    #printf "\n\nParameters error\n"
    exit 1
fi

#Default location Azure Access parameters
AzureSecretPath=$(realpath "$1")"/az-secrets"
AppFile="$AzureSecretPath/az-app-access.json"
SQLFile="$AzureSecretPath/az-sql-access.json"
UsrSecFile="$AzureSecretPath/secrets.json"
CStringFile="$AzureSecretPath/az-sql-con-string.json"

UsrSecPath=$(./user-secret-path.sh)

if [[ $2 == "app" ]]; then
    JsonFile=$AppFile
elif [[ $2 == "sql" ]]; then
    JsonFile=$SQLFile
elif [[ $2 == "usrsec" ]]; then

    if [[ "$4" == "" ]]; then
        #printf "\n\nParameters error\n"
        exit 1
    fi

    #use sed to extract User Secret GUID from cs.proj
    UsrSecId=$(sed -n 's:.*<UserSecretsId>\(.*\)</UserSecretsId>.*:\1:p' "$4")
    if [[ "$UsrSecPath" == "" ]] || [[ "$UsrSecId" == "" ]]; then
        #printf "\n\nParameters error\n"
        exit 1
    fi

    JsonFile="$UsrSecPath/$UsrSecId/secrets.json"

else
    exit 1
fi

if [[ -nz "$3" ]]; then

    Result=$(cat $JsonFile| grep -o '"'"$3"'": "[^"]*' | grep -o '[^"]*$')

    if [[ -nz "$Result" ]]; then
        echo $Result
        exit 0

    elif [[ $3 == "file" ]]; then
        echo "$JsonFile"
        exit 0
    elif [[ $3 == "path" ]]; then
        dirname $JsonFile
        exit 0
    elif [[ $3 == "fname" ]]; then
        basename $JsonFile
        exit 0
    elif [[ $3 == "cstring" ]]; then
        cat $CStringFile
        exit 0
    elif [[ $3 == "cstringfile" ]]; then
        echo $CStringFile
        exit 0
    fi
fi

#exit with error to catch in the test script
exit 1

