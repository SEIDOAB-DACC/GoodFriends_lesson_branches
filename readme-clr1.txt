To create the AppWebApi

1. In Configuration project, right click on Configuration.csproj and select manage User Secrets
   Replace all the content (probably empty) of secrets.json with the content of secret.json from the provided zip file 

2. Run AppWebApi with or without debugger

   Without debugger:   
   Open a Terminal in folder AppWebApi run: 
   dotnet run -lp https 
   open url: https://localhost:7066/swagger

3. You can now use and play with all endpoints