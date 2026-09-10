using System.Net;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Text.Json;
using HomeOffice.Application.Access;
using HomeOffice.Domain.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Logging;
using Npgsql;
using Xunit;

namespace HomeOffice.IntegrationTests;

public sealed class TestClock : TimeProvider
{
    private DateTimeOffset now = DateTimeOffset.UtcNow;
    public override DateTimeOffset GetUtcNow() => now;
    public void Advance(TimeSpan duration) => now += duration;
}

public sealed class CapturedEmail : IAccountEmail
{
    public Dictionary<string, (string Purpose, string Code)> Messages { get; } = [];
    public Task SendAsync(string email, string purpose, string code) { Messages[email] = (purpose, code); return Task.CompletedTask; }
}

public sealed class IdentityFixture : IAsyncDisposable
{
    public TestClock Clock { get; } = new();
    public CapturedEmail Email { get; } = new();
    public string Password { get; } = "Test9!" + Guid.NewGuid().ToString("N");
    public WebApplicationFactory<Program> Factory { get; private set; } = null!;
    public Member Employee { get; private set; } = null!;
    public Member Manager { get; private set; } = null!;
    public Member Admin { get; private set; } = null!;
    public Member Stranger { get; private set; } = null!;
    public string DirectoryPath { get; } = Path.Combine(Path.GetTempPath(), "ho003-" + Guid.NewGuid().ToString("N"));
    private string connection = "";
    private string databaseName = "ho003_test_" + Guid.NewGuid().ToString("N");

    public async Task InitializeAsync(bool production = false, int requestLimit = 1000, bool shortCodes = false)
    {
        var source = Environment.GetEnvironmentVariable("HO_TEST_DATABASE");
        Assert.False(string.IsNullOrWhiteSpace(source), "HO_TEST_DATABASE must point to real disposable PostgreSQL; never skip.");
        var admin = new NpgsqlConnectionStringBuilder(source) { Database = "postgres" };
        await using (var sql = new NpgsqlConnection(admin.ConnectionString))
        {
            await sql.OpenAsync();
            await using var command = new NpgsqlCommand($"CREATE DATABASE \"{databaseName}\"", sql);
            await command.ExecuteNonQueryAsync();
        }
        admin.Database = databaseName;
        connection = admin.ConnectionString;
        Directory.CreateDirectory(DirectoryPath);
        using var rsa = RSA.Create(2048);
        var certificateRequest = new CertificateRequest("CN=HomeOffice ephemeral test", rsa, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
        using var certificate = certificateRequest.CreateSelfSigned(DateTimeOffset.UtcNow.AddDays(-1), DateTimeOffset.UtcNow.AddDays(2));
        var certificatePath = Path.Combine(DirectoryPath, "test.pfx");
        await File.WriteAllBytesAsync(certificatePath, certificate.Export(X509ContentType.Pfx, Password));
        Factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment(production ? "Production" : "Testing");
            builder.ConfigureAppConfiguration((_, c) => c.AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["ConnectionStrings:Database"] = connection,
                ["Notifications:WorkerEnabled"] = production ? "true" : "false",
                ["Notifications:PushProvider"] = production ? "Disabled" : "Local",
                ["DataProtection:KeyDirectory"] = Path.Combine(DirectoryPath, "keys"),
                ["DataProtection:CertificatePath"] = certificatePath,
                ["DataProtection:CertificatePassword"] = Password,
                ["Email:Host"] = "smtp.example.invalid",
                ["Email:From"] = "test@example.invalid",
                ["Email:Username"] = "test",
                ["Email:Password"] = Password,
                ["Auth:RequestsPerMinute"] = production ? null : requestLimit.ToString(),
                ["Hosting:PublicOrigin"] = "https://localhost",
                ["Hosting:KnownProxies"] = "127.0.0.1",
                ["AllowedHosts"] = "localhost"
            }));
            builder.ConfigureLogging(logging => logging.ClearProviders());
            builder.ConfigureServices(services =>
            {
                // This fixture drives leases explicitly; production process tests run the real worker.
                var worker = services.SingleOrDefault(d => d.ServiceType == typeof(Microsoft.Extensions.Hosting.IHostedService) &&
                    d.ImplementationType == typeof(HomeOffice.Infrastructure.Notifications.NotificationWorker));
                if (worker is not null) services.Remove(worker);
                // The minimal host reads protection paths during registration. Explicitly isolate its
                // repository/certificate after that registration; never reuse a developer key ring.
                services.AddDataProtection().PersistKeysToFileSystem(new DirectoryInfo(Path.Combine(DirectoryPath, "keys")))
                    .ProtectKeysWithCertificate(X509CertificateLoader.LoadPkcs12FromFile(certificatePath, Password));
                services.RemoveAll<TimeProvider>(); services.AddSingleton<TimeProvider>(Clock);
                services.RemoveAll<IAccountEmail>(); services.AddSingleton<IAccountEmail>(Email);
                services.Configure<CookieAuthenticationOptions>(IdentityConstants.ApplicationScheme, o => o.TimeProvider = Clock);
                if (shortCodes) services.Configure<DataProtectionTokenProviderOptions>(o => o.TokenLifespan = TimeSpan.FromMilliseconds(10));
            });
        });
        await using var scope = Factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<HomeOfficeDbContext>();
        await db.Database.MigrateAsync();
        await db.Database.MigrateAsync(); // A second application of explicit migrations is safe.
        Assert.Empty(await db.Database.GetPendingMigrationsAsync());
        var first = new Organization { Name = "Synthetic primary" };
        var second = new Organization { Name = "Synthetic other" };
        db.Organizations.AddRange(first, second); await db.SaveChangesAsync();
        Employee = await AddMember(scope.ServiceProvider, first.Id, "employee", true, false, false);
        Manager = await AddMember(scope.ServiceProvider, first.Id, "manager", true, true, false);
        Admin = await AddMember(scope.ServiceProvider, first.Id, "admin", false, false, true);
        Stranger = await AddMember(scope.ServiceProvider, second.Id, "stranger", true, true, true);
        db.ReportingLines.Add(new() { OrganizationId = first.Id, EmployeeId = Employee.Id, ManagerId = Manager.Id });
        await db.SaveChangesAsync();
    }

    private async Task<Member> AddMember(IServiceProvider services, Guid organization, string name, bool employee, bool manager, bool admin)
    {
        var user = new IdentityUser { Email = name + "@test.example", UserName = name + "@test.example", EmailConfirmed = true, LockoutEnabled = true };
        var users = services.GetRequiredService<UserManager<IdentityUser>>();
        Assert.True((await users.CreateAsync(user, Password)).Succeeded);
        var member = new Member
        {
            OrganizationId = organization,
            IdentityUserId = user.Id,
            DisplayName = name,
            IsEmployee = employee,
            IsManager = manager,
            IsAccountAdministrator = admin
        };
        var db = services.GetRequiredService<HomeOfficeDbContext>(); db.Members.Add(member); await db.SaveChangesAsync();
        return member;
    }

    public HttpClient Client() => Factory.CreateClient(new WebApplicationFactoryClientOptions { BaseAddress = new Uri("https://localhost"), AllowAutoRedirect = false, HandleCookies = true });
    public async Task<string> Csrf(HttpClient client)
    {
        using var response = await client.GetAsync("/api/v1/auth/csrf");
        response.EnsureSuccessStatusCode();
        return JsonDocument.Parse(await response.Content.ReadAsStringAsync()).RootElement.GetProperty("requestToken").GetString()!;
    }
    public async Task<HttpResponseMessage> WebLogin(HttpClient client, string name = "employee")
    {
        using var request = new HttpRequestMessage(HttpMethod.Post, "/api/v1/auth/web/login") { Content = JsonContent.Create(new { email = name + "@test.example", password = Password }) };
        request.Headers.Add("X-CSRF-TOKEN", await Csrf(client));
        return await client.SendAsync(request);
    }
    public async Task<JsonElement> TokenLogin(HttpClient client, string name = "employee")
    {
        using var response = await client.PostAsJsonAsync("/api/v1/auth/token/login", new { email = name + "@test.example", password = Password });
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        return JsonDocument.Parse(await response.Content.ReadAsStringAsync()).RootElement.Clone();
    }
    public static void Bearer(HttpClient client, JsonElement tokens) => client.DefaultRequestHeaders.Authorization = new("Bearer", tokens.GetProperty("accessToken").GetString());

    public async ValueTask DisposeAsync()
    {
        if (Factory is not null) await Factory.DisposeAsync();
        NpgsqlConnection.ClearAllPools();
        if (!string.IsNullOrEmpty(connection))
        {
            Assert.StartsWith("ho003_test_", databaseName);
            var admin = new NpgsqlConnectionStringBuilder(connection) { Database = "postgres" };
            await using var sql = new NpgsqlConnection(admin.ConnectionString); await sql.OpenAsync();
            await using var command = new NpgsqlCommand($"DROP DATABASE \"{databaseName}\" WITH (FORCE)", sql); await command.ExecuteNonQueryAsync();
        }
        var resolvedDirectory = Path.GetFullPath(DirectoryPath);
        Assert.StartsWith(Path.GetFullPath(Path.GetTempPath()), resolvedDirectory);
        Assert.StartsWith("ho003-", Path.GetFileName(resolvedDirectory));
        if (Directory.Exists(resolvedDirectory)) Directory.Delete(resolvedDirectory, recursive: true);
    }
}
