using System.Reflection;
using System.Text.RegularExpressions;

namespace AppWebApi
{
    /// <summary>
    /// Represents version and build information about the application
    /// </summary>
    public class VersionInfo
    {
        public string AssemblyVersion { get; set; }
        public string FileVersion { get; set; }
        public string InformationalVersion { get; set; }
        public string GitCommitHash { get; set; }


        public string BuildTime { get; set; }
        public string BuildMachine { get; set; }
        public string BuildUser { get; set; }

        public string Company { get; set; }
        public string Product { get; set; }
        public string Description { get; set; }
        public string Copyright { get; set; }
        public string CompanyUrl { get; set; }

        /// <summary>
        /// Creates a VersionInfo object from the current assembly
        /// </summary>
        /// <returns>A populated VersionInfo object</returns>
        public static VersionInfo FromAssembly()
        {
            var assembly = Assembly.GetExecutingAssembly();
            var assemblyName = assembly.GetName();

            var informationalVersion = assembly.GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion ?? "Unknown";
            var gitCommitHash = ExtractGitCommitHash(informationalVersion);

            return new VersionInfo
            {
                AssemblyVersion = assemblyName.Version?.ToString() ?? "Unknown",
                FileVersion = assembly.GetCustomAttribute<AssemblyFileVersionAttribute>()?.Version ?? "Unknown",
                InformationalVersion = informationalVersion,
                GitCommitHash = gitCommitHash,

                BuildTime = GetAssemblyMetadata(assembly, "BuildTime") ?? "Unknown",
                BuildMachine = GetAssemblyMetadata(assembly, "BuildMachine") ?? "Unknown",
                BuildUser = GetAssemblyMetadata(assembly, "BuildUser") ?? "Unknown",

                Company = assembly.GetCustomAttribute<AssemblyCompanyAttribute>()?.Company ?? "Unknown",
                Product = assembly.GetCustomAttribute<AssemblyProductAttribute>()?.Product ?? "Unknown",
                Description = assembly.GetCustomAttribute<AssemblyDescriptionAttribute>()?.Description ?? "Unknown",
                Copyright = assembly.GetCustomAttribute<AssemblyCopyrightAttribute>()?.Copyright ?? $"Copyright © Unknown {DateTime.UtcNow.Year}",
                CompanyUrl = GetAssemblyMetadata(assembly, "CompanyUrl") ?? "Unknown"
            };
        }
        private static string GetAssemblyMetadata(Assembly assembly, string key)
        {
            return assembly.GetCustomAttributes<AssemblyMetadataAttribute>()
                          .FirstOrDefault(attr => attr.Key == key)?.Value;
        }

        private static string ExtractGitCommitHash(string informationalVersion)
        {
            if (string.IsNullOrEmpty(informationalVersion))
                return "Unknown";

            // Use regex to extract git commit hash after '+' character
            // Pattern matches '+' followed by alphanumeric characters (git hash)
            var match = Regex.Match(informationalVersion, @"\+([a-fA-F0-9]+)");
            if (match.Success)
            {
                var hashPart = match.Groups[1].Value;
                // Take first 7-10 characters as short hash, or full if shorter
                return hashPart.Length > 10 ? hashPart.Substring(0, 10) : hashPart;
            }

            return "Unknown";
        }
    }
}
