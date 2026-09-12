using System.Net;
using Microsoft.AspNetCore.HttpOverrides;
using Npgsql;

namespace HomeOffice.Api;

public static class ProductionHosting
{
    public static void Configure(IServiceCollection services, IConfiguration config, IHostEnvironment environment, bool contract)
    {
        if (contract || environment.IsDevelopment() || environment.IsEnvironment("Testing")) return;
        services.AddOptions<HostingRequirements>().Configure(o => o.Valid = IsValid(config))
            .Validate(o => o.Valid, "Production hosting configuration is incomplete or unsafe; see infra/pilot/README.md.")
            .ValidateOnStart();
        services.Configure<ForwardedHeadersOptions>(o =>
        {
            o.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
            o.ForwardLimit = 1;
            o.KnownProxies.Clear();
            o.KnownIPNetworks.Clear();
            foreach (var address in (config["Hosting:KnownProxies"] ?? "").Split(';', StringSplitOptions.RemoveEmptyEntries))
                if (IPAddress.TryParse(address, out var ip)) o.KnownProxies.Add(ip);
        });
    }

    public static bool IsValid(IConfiguration config)
    {
        var origin = config["Hosting:PublicOrigin"];
        var proxies = (config["Hosting:KnownProxies"] ?? "").Split(';', StringSplitOptions.RemoveEmptyEntries);
        var forbidden = new[] { "Auth:CookieSeconds", "Auth:AccessTokenSeconds", "Auth:RefreshTokenSeconds", "Auth:RequestsPerMinute", "Email:CaptureDirectory" };
        var secrets = new[] { "ConnectionStrings:Database", "DataProtection:CertificatePassword", "Email:Password" };
        return Uri.TryCreate(origin, UriKind.Absolute, out var uri) && uri.Scheme == "https" &&
            uri.AbsolutePath == "/" && uri.Query == "" && uri.Fragment == "" && uri.UserInfo == "" &&
            config["AllowedHosts"] == uri.Host &&
            proxies.Length > 0 && proxies.All(a => IPAddress.TryParse(a, out var ip) &&
                !ip.Equals(IPAddress.Any) && !ip.Equals(IPAddress.IPv6Any)) &&
            forbidden.All(k => config[k] is null) &&
            secrets.All(k => !string.IsNullOrWhiteSpace(config[k]) && !config[k]!.Contains("REPLACE", StringComparison.OrdinalIgnoreCase)) &&
            DatabaseConfigured(config.GetConnectionString("Database")) &&
            config.GetValue("Notifications:WorkerEnabled", true) &&
            config.GetValue("Email:Port", 587) is > 0 and <= 65535 &&
            (!string.Equals(config["Notifications:PushProvider"], "Fcm", StringComparison.OrdinalIgnoreCase) || !string.IsNullOrWhiteSpace(config["Notifications:FirebaseProjectId"])) &&
            Path.IsPathFullyQualified(config["DataProtection:KeyDirectory"] ?? "") &&
            Path.IsPathFullyQualified(config["DataProtection:CertificatePath"] ?? "");
    }

    private static bool DatabaseConfigured(string? connection)
    {
        try
        {
            var parsed = new NpgsqlConnectionStringBuilder(connection);
            return !string.IsNullOrWhiteSpace(parsed.Host) && !string.IsNullOrWhiteSpace(parsed.Database) &&
                !string.IsNullOrWhiteSpace(parsed.Username) && !string.IsNullOrWhiteSpace(parsed.Password);
        }
        catch (ArgumentException) { return false; }
    }
}

public sealed class HostingRequirements { public bool Valid { get; set; } }
