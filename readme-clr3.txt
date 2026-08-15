This text shows the steps to publish run AppWebApi from Azure App Services.

You need to have done ALL the steps in readme-clr1.txt before doing below steps.
(You need to have run Admin/SeedUsers so users are into the database
 You need to have run Admin/Seed so data is seeded into the database)


First, preparation to publish is done by building and running production AppWebApi locally.
Then, the the actual publishing of AppWebApi is done.
Finally, the AppWebApi running on Azure is launched in the browser


Prepare to publish by building for production but running locally
-----------------------------------------------------------------

1. With Terminal in folder _scripts run
  
   ./az-prep-publish.sh ../AppWebApi ../Configuration/Configuration.csproj
  or
   ./az-prep-publish.ps1 ../AppWebApi ../Configuration/Configuration.csproj

2. After completion you will see:
    Run the webapi from the published directory...
    Executing application: AppWebApi
    Using Secret Storage: AzureKeyVault
    Using Azure Key Vault in Production environment.
    Azure Key Vault added successfully.
    info: Microsoft.Hosting.Lifetime[14]
          Now listening on: https://localhost:5001

3. open url: https://localhost:5001/swagger

4. Verify database seed with endpoint Admin/Environment and Guest/Info. You will see the overview of the local database content

5. Use endpoint Guest/LoginUser to login as sysadmin1
{
  "userNameOrEmail": "dbo1",
  "password": "dbo1"
}

6. Authorize using Swagger Authorize butto and paste in the encryptedToken recieved after login.
    NOTE!!: Copy and paste the encryptedToken WITHIN the quotation, i.e. WITHOUT the first and last quotation mark "

7. As dbo you can now use and play with all endpoints.
   Note that all the seeding related endpoints are no longer available as we are running a production version


Publish AppWebApi to Azure App Service
--------------------------------------

8. In Azure tab on VSC open App Services find the newly created Web Application Service

9. Right click on the App Service and select "Deploy to Web App...". Click deploy. 

10. Choose "skip for now" if VSC is asking to "Always to deploy to workspace" deployment


Launch AppWebApi running on Azure in the browser
------------------------------------------------

11. After deployment browse to website. 
    You can rightclick on the App Service to deployed to and select "Browse Website"
    NOTE!!: remember to add /swagger at the end of the url to see the swagger interface.

