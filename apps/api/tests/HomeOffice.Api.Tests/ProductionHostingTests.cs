using HomeOffice.Api;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace HomeOffice.Api.Tests;

public class ProductionHostingTests
{
    [Theory]
    [InlineData("Hosting:PublicOrigin", "http://pilot.example")]
    [InlineData("Hosting:KnownProxies", "")]
    [InlineData("Hosting:KnownProxies", "0.0.0.0")]
    [InlineData("AllowedHosts", "*")]
    [InlineData("Auth:RequestsPerMinute", "1000")]
    [InlineData("Email:CaptureDirectory", "/tmp/capture")]
    [InlineData("Notifications:WorkerEnabled", "false")]
    [InlineData("DataProtection:CertificatePassword", "REPLACE_ME")]
    [InlineData("ConnectionStrings:Database", "Host=database;Database=homeoffice;Username=homeoffice")]
    [InlineData("ConnectionStrings:Database", "invalid connection")]
    [InlineData("Notifications:PushProvider", "fcm")]
    public void Unsafe_production_configuration_is_rejected(string key, string value)
    {
        var data = Valid();
        Assert.True(ProductionHosting.IsValid(new ConfigurationBuilder().AddInMemoryCollection(data).Build()));
        data[key] = value;
        Assert.False(ProductionHosting.IsValid(new ConfigurationBuilder().AddInMemoryCollection(data).Build()));
    }

    private static Dictionary<string, string?> Valid() => new()
    {
        ["Hosting:PublicOrigin"] = "https://pilot.example",
        ["Hosting:KnownProxies"] = "10.77.0.2",
        ["AllowedHosts"] = "pilot.example",
        ["ConnectionStrings:Database"] = "Host=database;Database=homeoffice;Username=homeoffice;Password=synthetic-only",
        ["DataProtection:CertificatePassword"] = "synthetic-only",
        ["DataProtection:KeyDirectory"] = Path.GetTempPath(),
        ["DataProtection:CertificatePath"] = Path.Combine(Path.GetTempPath(), "test.pfx"),
        ["Email:Password"] = "synthetic-only"
    };
}
