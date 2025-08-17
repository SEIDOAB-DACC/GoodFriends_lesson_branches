To create the AppWebApi

1. Create the database. With Terminal in folder _scripts 
   
   macOs
   ./database-rebuild-all.sh sqlserver docker
   ./database-rebuild-all.sh mysql docker
   ./database-rebuild-all.sh postgresql docker
   
   Windows
   ./database-rebuild-all.ps1 sqlserver docker
   ./database-rebuild-all.ps1 mysql docker
   ./database-rebuild-all.ps1 postgresql docker

   Ensure no errors from build, migration or database update


2. From Azure Data Studio you can now connect to the database
   Use connection string from user secrets:
   connection string corresponding to Tag
   "sql-friends.<db_type>.docker.root"

3. Run AppWebApi with or without debugger

   Without debugger:   
   Open a Terminal in folder AppWebApi run: 
   dotnet run -lp https 
   open url: https://localhost:7066/swagger

   Verify your can execute endpoints
      Admin/Environment, Admin/Version and Admin/Log

4. Use From Azure Data Studio to explore the created database and it's schema 
   Notice that only tables are implemented in the database, not foreign keys, as the model realtionships is not defined