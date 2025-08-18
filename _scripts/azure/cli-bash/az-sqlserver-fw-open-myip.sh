#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-sqlserver-fw-open-myip.sh
#Opens the firewall for my current ip ranging from .0 to .255 on the Azure SqlServer

#To execute:
#./az-sqlserver-fw-open-myip.sh ../az-resource-params/data-access

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

# Get current public IP address
printf "\n\nDetecting current public IP address...\n"
CurrentIp=$(curl -s https://ipinfo.io/ip)
if [ -z "$CurrentIp" ]; then
    printf "Error: Could not detect current IP address\n"
    exit 1
fi
printf "Current IP address: $CurrentIp\n"

# Create IP range from current IP subnet (0-255 for last octet)
IpBase=$(echo $CurrentIp | cut -d'.' -f1-3)
SqlFirewallStartIp="${IpBase}.0"
SqlFirewallEndIp="${IpBase}.255"
printf "IP range: $SqlFirewallStartIp - $SqlFirewallEndIp\n"

#https://learn.microsoft.com/en-us/cli/azure/sql/server/firewall-rule?view=azure-cli-latest
printf "\n\nConfiguring firewall...\n"
docker exec -it $AzureCliContainer az sql server firewall-rule create --resource-group $ResourceGroup --server $SqlServerName -n AllowYourIp --start-ip-address $SqlFirewallStartIp --end-ip-address $SqlFirewallEndIp
docker exec -it $AzureCliContainer az sql server firewall-rule create --resource-group $ResourceGroup --server $SqlServerName -n AllowAllWindowsAzureIps --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0


#only come here if all previous commands were successful
printf "\n\nSuccess! All commands completed successfully!\n"