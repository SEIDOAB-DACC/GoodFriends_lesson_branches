using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using System.Xml.Linq;
using System.Runtime.CompilerServices;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration.UserSecrets;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;

namespace Configuration.Extensions;

public static class SecretsExtensions
{
    const string _appsettingfile = "appsettings.json";

    //to use either user secrets or azure key vault depending on UseAzureKeyVault tag in appsettings.json
    //Azure key vault access parameters location are set in <AzureProjectSettings> tag in the csproj file
    //User secret id is set in <UserSecretsId>
    public static IConfigurationBuilder AddSecrets(this IConfigurationBuilder config, IHostEnvironment environment, string appFolder)
    {
        // current directory is either the application or the dbContext when running migrations
        var currentDir = Directory.GetCurrentDirectory();
#if DEBUG
        config.SetBasePath(Path.Combine(currentDir, "..", appFolder))
                .AddJsonFile(_appsettingfile, optional: true, reloadOnChange: true);
#else        
        config.SetBasePath(currentDir)
                .AddJsonFile(_appsettingfile, optional: true, reloadOnChange: true);
#endif
        Environment.SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "Production");

        // Build a temporary configuration to read the SecretStorage setting
        var tempConfig = config.Build();
        string secretStorage = tempConfig.GetValue<string>("ApplicationSecrets:SecretStorage");
        Console.WriteLine($"Using Secret Storage: {secretStorage}");

        //to use either user secrets or azure key vault depending on SecretStorage tag in appsettings.json
        if (environment.IsDevelopment())
        {
            Environment.SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "Development");
            var assembly = System.Reflection.Assembly.Load("Configuration");

            if (secretStorage == "UserSecrets")
            {
                // In development, we use user secrets
                Console.WriteLine("Using User Secrets in Development environment.");

                // Load user secrets from Configuration project assembly
                config.AddUserSecrets(assembly);

                // Read the UserSecretsId programmatically
                var userSecretsIdAttribute = assembly.GetCustomAttributes(typeof(UserSecretsIdAttribute), false)
                    .FirstOrDefault() as UserSecretsIdAttribute;
                var userSecretsId = userSecretsIdAttribute?.UserSecretsId;
                Console.WriteLine($"Using User Secrets ID: {userSecretsId}");
            }
            else if (secretStorage == "AzureKeyVault")
            {
                // In development, we use Azure Key Vault
                Console.WriteLine("Using Azure Key Vault in Development environment.");

                string azureSettings = tempConfig.GetValue<string>("ApplicationSecrets:AzureSettings");
                Console.WriteLine($"AzureSettings: {azureSettings}");

                // Show some environment variables to access Azure Key Vault 
                var _vaultAccess = AzureKeyVaultExtensions.PrepareDevelopmentAccess(tempConfig);
                Console.WriteLine($"AZURE_KeyVaultSecret: {_vaultAccess["kvSecret"]}");

                config.AddAzureKeyVault();
                var secretname = Environment.GetEnvironmentVariable("AZURE_KeyVaultSecret");
                Console.WriteLine($"Azure Key Vault Secrets {secretname} read successfully.");
            }
            else
            {
                throw new InvalidOperationException("Invalid SecretStorage value. Use 'UserSecrets' or 'AzureKeyVault'.");
            }
        }
        else
        {
            // In production
            if (secretStorage == "AzureKeyVault")
            {
                config.AddAzureKeyVault();
                var secretname = Environment.GetEnvironmentVariable("AZURE_KeyVaultSecret");
                Console.WriteLine($"Azure Key Vault Secrets {secretname} read successfully.");
            }
            else
            {
                throw new InvalidOperationException("Invalid SecretStorage value. Use 'AzureKeyVault' for production.");
            }
        }

        return config;
    }
}

