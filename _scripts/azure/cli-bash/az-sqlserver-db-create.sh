#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./az-sqlserver-db-create.sh

#Creates an Azure SqlDatabase

#To execute:
#./az-sqlserver-db-create.sh ../az-resource-params/data-access

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
SqlDbName=$(./az-access.sh $1 sqlDb)

SqlServerSa=$(./az-access-secrets.sh $1 sql sqlRootUser)
SqlServerSaPassword=$(./az-access-secrets.sh $1 sql sqlRootPassword)
SqlDbCStringFile=$(./az-access-secrets.sh $1 sql cstringfile)

#create the container registry
#https://learn.microsoft.com/en-us/azure/azure-sql/database/scripts/create-and-configure-database-cli?view=azuresql
#https://learn.microsoft.com/en-us/azure/azure-sql/database/serverless-tier-overview?view=azuresql&tabs=general-purpose
printf "\n\nCreating $SqlDbName on $SqlServerName...\n"
docker exec -it $AzureCliContainer az sql db create --resource-group $ResourceGroup --server $SqlServerName --name $SqlDbName \
  --edition GeneralPurpose --compute-model Serverless --family Gen5 --capacity 1


printf "\n\nGenerating ADO.Net Connection String...\n"
ConnectionString=$(docker exec -it $AzureCliContainer az sql db show-connection-string --name $SqlDbName \
 --client ado.net --server $SqlServerName)

# Replace placeholders with actual credentials and remove quotes
ConnectionString=${ConnectionString//<username>/$SqlServerSa}
ConnectionString=${ConnectionString//<password>/$SqlServerSaPassword}
ConnectionString=${ConnectionString//\"/}
ConnectionString=${ConnectionString//[$'\r\n']/}  # Remove any carriage returns/newlines

# Create connection strings for all user roles
RootConnectionString="$ConnectionString"
DboConnectionString="${ConnectionString//User ID=$SqlServerSa/User ID=dboUser}"
DboConnectionString="${DboConnectionString//Password=$SqlServerSaPassword/Password=pa\$Word1}"

SupusrConnectionString="${ConnectionString//User ID=$SqlServerSa/User ID=supusrUser}"
SupusrConnectionString="${SupusrConnectionString//Password=$SqlServerSaPassword/Password=pa\$Word1}"

UsrConnectionString="${ConnectionString//User ID=$SqlServerSa/User ID=usrUser}"
UsrConnectionString="${UsrConnectionString//Password=$SqlServerSaPassword/Password=pa\$Word1}"

GstusrConnectionString="${ConnectionString//User ID=$SqlServerSa/User ID=gstusrUser}"
GstusrConnectionString="${GstusrConnectionString//Password=$SqlServerSaPassword/Password=pa\$Word1}"

# Create JSON structure with all connection strings
cat > "$SqlDbCStringFile" << EOF
{
    "sql-friends.sqlserver.azure.root": "$RootConnectionString",
    "sql-friends.sqlserver.azure.dbo": "$DboConnectionString",
    "sql-friends.sqlserver.azure.supusr": "$SupusrConnectionString",
    "sql-friends.sqlserver.azure.usr": "$UsrConnectionString",
    "sql-friends.sqlserver.azure.gstusr": "$GstusrConnectionString"
}
EOF

printf "\nRole based connection strings to $SqlDbName on $SqlServerName are stored in $SqlDbCStringFile\n"
printf "\nRoot connection string is:\n"
printf "%s\n" "$RootConnectionString"


#only come here if all previous commands were successful
printf "\n\nSuccess! All commands completed successfully!\n"