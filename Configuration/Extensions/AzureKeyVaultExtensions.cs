using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using System.Xml.Linq;
using System.Runtime.CompilerServices;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration.UserSecrets;
using Microsoft.Extensions.Hosting;

namespace Configuration;

public static class AzureKeyVaultExtensions
{
    public static IConfigurationBuilder AddAzureKeyVault(this IConfigurationBuilder configuration)
    {
        var vaultUri = new Uri(Environment.GetEnvironmentVariable("AZURE_KeyVaultUri"));
        var tenantId = Environment.GetEnvironmentVariable("AZURE_TENANT_ID");
        var clientId = Environment.GetEnvironmentVariable("AZURE_CLIENT_ID");
        var clientSecret = Environment.GetEnvironmentVariable("AZURE_CLIENT_SECRET");
        var secretname = Environment.GetEnvironmentVariable("AZURE_KeyVaultSecret");

        //Open the AZKV from creadentials in the environment variables
        var credential = new ClientSecretCredential(tenantId, clientId, clientSecret);
        var client = new SecretClient(vaultUri, credential);

        var secret = client.GetSecret(secretname);
        var userSecretsJson = secret.Value.Value;

        if (string.IsNullOrEmpty(userSecretsJson))
        {
            throw new Exception("The secret value is empty. Please check your Azure Key Vault configuration.");
        }

        //Adding content from Azure Key Vault as a JSON stream
        var stream = new MemoryStream(System.Text.Encoding.UTF8.GetBytes(userSecretsJson));
        configuration.AddJsonStream(stream);

        return configuration;
    }

    //For Debug: Read and set them from Vault and set Environment variables
    //For Production: Will be set as Environment variables as part of the deployment process
    public static IConfigurationRoot PrepareDevelopmentAccess(IConfigurationRoot conf)
    {
        string azureKeyVaultSettings = conf.GetValue<string>("ApplicationSecrets:AzureSettings") + "/az-access/az-settings.json";
        string azureKeyVaultSecrets = conf.GetValue<string>("ApplicationSecrets:AzureSettings") + "/az-secrets/az-app-access.json";

        // Set environment variables to access Azure Key Vault 
        var _vaultAccess = new ConfigurationBuilder()
            .AddJsonFile(azureKeyVaultSettings, optional: true, reloadOnChange: true)
            .AddJsonFile(azureKeyVaultSecrets, optional: true, reloadOnChange: true)
            .Build();

        //A deployed WebApp will use environment variables, so here I set them during DEBUG
        Environment.SetEnvironmentVariable("AZURE_TENANT_ID", _vaultAccess["tenantId"]);
        Environment.SetEnvironmentVariable("AZURE_KeyVaultSecret", _vaultAccess["kvSecret"]);
        Environment.SetEnvironmentVariable("AZURE_KeyVaultUri", _vaultAccess["kvUri"]);
        Environment.SetEnvironmentVariable("AZURE_CLIENT_SECRET", _vaultAccess["password"]);
        Environment.SetEnvironmentVariable("AZURE_CLIENT_ID", _vaultAccess["appId"]);

        return _vaultAccess;
    }
}