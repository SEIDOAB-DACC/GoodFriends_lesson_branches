To create the AppWebApi, all Azure resources and publish using Azure portal

1. Create all resources in Azure using the grafic portal
   Resource group, 
   KeyVault, 
   Application tenant to with role KeyVaultReader, 
   SQL Server
   SQL Server database
   
2. In UserSecrets update Sql Server database connection strings based on the root user connection string you setup

    "db-5372.sqlserver.azure.root": "...; User ID=<your name>;Password=<your strong password>; ...",
    "db-5372.sqlserver.azure.dbo": "...; User ID=dboUser;Password=pa$Word1; ...",
    "db-5372.sqlserver.azure.supusr": "...; User ID=supusrUser;Password=pa$Word1; ...",
    "db-5372.sqlserver.azure.usr": "...; User ID=usrUser;Password=pa$Word1; ...",
    "db-5372.sqlserver.azure.gstusr": "...; User ID=gstusrUser;Password=pa$Word1; ..."

3. In UserSecrets update KeyVaultAccess parameters
  "AzureKeyVault": {
    "kvAccessParams": {
      "kvUri": "the https: url from Azure KeyVault",
      "kvSecret": "the name of the secret you created in the KeyVault",
      "readerSecrets": {
        "appId": "from the creating of Application tenant to with role KeyVaultReader",
        "displayName": "from the creating of Application tenant to with role KeyVaultReader",
        "password": "from the creating of Application tenant to with role KeyVaultReader",
        "tenant": "Your Azure tenant id"
      }
    }
  }


4. You can always update Azure KeyVault with the content of your user secrets by copying the json file into the secret you created in the KeyVault
   You can always switch back and forth between reading the user secrets from Azure KeyVault or local UserSecrets by setting in appsettings.json
   
   "ApplicationSecrets": {
        "SecretStorage": "AzureKeyVault" // Options: "UserSecrets", "AzureKeyVault"
    },


5. Migrate and update the database. With Terminal in folder _scripts 
   
      ./database-rebuild-all.sh sql-friends sqlserver azure dbo ../AppWebApi
   or   
      .\database-rebuild-all.ps1 sql-friends sqlserver azure dbo ..\AppWebApi

   Ensure no errors from build, migration or database update


6. From Azure Data Studio you can now connect to the database
   Use connection string from user secrets:
   connection string corresponding to Tag
   "sql-friends.sqlserver.azure.root"

7. Use Azure Data Studio to execute SQL script DbContext/SqlScripts/<db_type>/azure/initDatabase.sql

8. Run AppWebApi with or without debugger

   Without debugger:   
   Open a Terminal in folder AppWebApi run: 
   dotnet run -lp https 
   open url: https://localhost:7066/swagger

   Verify your can execute endpoint Admin/Environment, Admin/Version and Guest/Info

9. Use endpoint Admin/SeedUsers to seed users into the database

10. Use endpoint Guest/LoginUser to login as dbo1
{
  "userNameOrEmail": "dbo1",
  "password": "dbo1"
}

11. Authorize using Swagger Authorize butto and paste in the encryptedToken recieved after login.
    NOTE!!: Copy and paste the encryptedToken WITHIN the quotation, i.e. WITHOUT the first and last quotation mark "

12. Use endpoint Admin/Seed to seed the database, Admin/RemoveSeed to remove the seed
   Verify database seed with endpoint Guest/Info
   As dbo you can now use and play with all endpoints
