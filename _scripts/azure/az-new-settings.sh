#!/bin/bash
# az-new-settings.sh
# Bash script using the template file az-settings-template.json to create a new az-settings.json file

# Usage:
# ./az-new-settings.sh ./az-resource-params/data-access

set -e

# Check if required parameter is provided
if [ $# -eq 0 ]; then
    printf "Error: Azure project settings path is required\n"
    printf "Usage: %s <azure-project-settings-path>\n" "$0"
    exit 1
fi

AZURE_PROJECT_SETTINGS="$1"

# Resolve absolute path
AZURE_PROJECT_SETTINGS=$(realpath "$AZURE_PROJECT_SETTINGS")

# Get file and template paths using az-access.sh
AZURE_FILE=$(./cli-bash/az-access.sh "$AZURE_PROJECT_SETTINGS" file)
AZURE_TEMPLATE=$(./cli-bash/az-access.sh "$AZURE_PROJECT_SETTINGS" template)

# Generate random suffixes
SUFFIX8=$(uuidgen | grep -o '[0-9a-f]' | head -n 8 | tr -d '\n')
printf "Using suffix8: %s\n" "$SUFFIX8"

SUFFIX4=$(uuidgen | grep -o '[0-9a-f]' | head -n 4 | tr -d '\n')
printf "Using suffix4: %s\n" "$SUFFIX4"

# Read template content and replace placeholders
CONTENT=$(cat "$AZURE_TEMPLATE" | sed "s/<suffix8>/$SUFFIX8/g" | sed "s/<suffix4>/$SUFFIX4/g")

# Create backup of existing file if it exists
if [ -f "$AZURE_FILE" ]; then
    BACKUP_FILE="${AZURE_FILE}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$AZURE_FILE" "$BACKUP_FILE"
    printf "Backup created: %s\n" "$BACKUP_FILE"
fi

# Write the new content to the file
printf "%s" "$CONTENT" > "$AZURE_FILE"

printf "Azure settings file created: %s\n" "$AZURE_FILE"
