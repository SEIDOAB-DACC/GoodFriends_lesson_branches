#!/bin/bash
#To make the .sh file executable
#sudo chmod +x ./database-rebuild-all.sh

#If EFC tools needs update use:
#dotnet tool update --global dotnet-ef

# To execute:
#./database-rebuild-all.sh sqlserver [docker|azure]
#./database-rebuild-all.sh mysql [docker|azure]
#./database-rebuild-all.sh postgresql [docker|azure]

#Set Database Context
if [[ $1 == "sqlserver" ]]; then
    DBContext="SqlServerDbContext"

elif [[ $1 == "mysql" ]]; then
    DBContext="mysqlDbContext"

elif [[ $1 == "postgresql" ]]; then
    DBContext="PostgresDbContext"

else
    printf "\nMissing parameters:\n  ./database-rebuild-all.sh [sqlserver|mysql|postgres] [docker|azure]\n"
    exit 1;
fi

if [[ -z "$2" ]]; then
    printf "\nInvalid second parameter, must be 'docker' or 'azure':\n  ./database-rebuild-all.sh [sqlserver|mysql|postgres] [docker|azure]\n"
    exit 1
fi

if [[ $2 != "docker" && $2 != "azure" ]]; then
    printf "\nInvalid second parameter, must be 'docker' or 'azure':\n  ./database-rebuild-all.sh [sqlserver|mysql|postgres] [docker|azure]\n"
    exit 1
fi

#set UseDataSetWithTag to "<db_name>.<db_type>.<env>" in appsettings.json
sed -i '' 's/"UseDataSetWithTag":[[:space:]]*"[^"]*"/"UseDataSetWithTag": "sql-friends.'$1'.'$2'"/g' ../AppWebApi/appsettings.json

#set DefaultDataUser to "root"
sed -i '' 's/"DefaultDataUser":[[:space:]]*"[^"]*"/"DefaultDataUser": "root"/g' ../AppWebApi/appsettings.json

if [[ $2 == "docker" ]]; then
    #drop any database
    dotnet ef database drop -f -c $DBContext -p ../DbContext -s ../DbContext
fi

#remove any migration
rm -rf ../DbContext/Migrations/$DBContext

#make a full new migration
dotnet ef migrations add miInitial -c $DBContext -p ../DbContext -s ../DbContext -o ../DbContext/Migrations/$DBContext

#update the database from the migration
dotnet ef database update -c $DBContext -p ../DbContext -s ../DbContext

#to initialize the database you need to run the sql scripts
#../DbContext/SqlScripts/<db_type>/initDatabase.sql

