#!/bin/bash
# az-access.sh
# Usage: ./az-access.sh {az-resource-params path} [{json-key}|file|template|path|fname]

#To make the .sh file executable
#sudo chmod +x ./az-access.sh

# Check if both parameters are provided
if [ $# -ne 2 ]; then
    echo "Error: Both access path and key parameters are required" >&2
    echo "Usage: $0 {az-access-path} [{json-key}|file|template|path|fname]" >&2
    exit 1
fi

ACCESS_PATH="$1"
KEY="$2"

# Resolve absolute path and set JSON file paths
ABS_PATH=$(realpath "$ACCESS_PATH")
AZ_ACCESS_PATH="$ABS_PATH/az-access"
JsonFile="$AZ_ACCESS_PATH/az-settings.json"
TemplateFile="$AZ_ACCESS_PATH/az-settings-template.json"

if [[ -nz "$KEY" ]]; then
    Result=$(cat $JsonFile | grep -o '"'"$KEY"'": "[^"]*' | grep -o '[^"]*$')

    if [[ -nz "$Result" ]]; then
        echo $Result
        exit 0    
    elif [[ $2 == "file" ]]; then
        echo "$JsonFile"
        exit 0
    elif [[ $2 == "template" ]]; then
        echo "$TemplateFile"
        exit 0
    elif [[ $2 == "path" ]]; then
        dirname $JsonFile
        exit 0
    elif [[ $2 == "fname" ]]; then
        basename $JsonFile
        exit 0
    fi
fi

# Exit with error to catch in the test script
echo "Error: Key '$KEY' not found in settings" >&2
exit 1