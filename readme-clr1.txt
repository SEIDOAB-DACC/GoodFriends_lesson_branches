To create the AppWebApi

1. Delete folder DbContext/Migrations

2. Create a new database. With Terminal in folder DbContext execute below EFC cli
   
   Remove any database
      dotnet ef database drop -f 
   
   Make a migration
      dotnet ef migrations add initial_migration
   
   Create/update the database schema from Migrations
      dotnet ef database update

   Ensure no errors from build, migration or database update


3. From Azure Data Studio you can now connect to the database from the connection string in appsettings.json

   "ConnectionStrings": {
         "SqlServerDocker": "...""
   }

4. Run AppWebApi with or without debugger

   Without debugger:   
   Open a Terminal in folder AppWebApi run: 
   dotnet run -lp https 
   open url: https://localhost:7066/swagger

   Verify your can execute endpoints
      Admin/Environment, Admin/Version and Admin/Log

5. Use From Azure Data Studio to explore the created database and it's schema 
   Notice that one table is implemented in the database

6. Use endpoint Admin/Seed to fill the database Quote table with content.
   Check the content using Azure Data Studio
