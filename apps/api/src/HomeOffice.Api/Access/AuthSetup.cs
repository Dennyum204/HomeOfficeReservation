using System.Security.Cryptography.X509Certificates;
using System.Threading.RateLimiting;
using HomeOffice.Application.Access;
using HomeOffice.Infrastructure.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authentication.BearerToken;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.RateLimiting;

namespace HomeOffice.Api.Access;

public static class AuthSetup
{
    public static IServiceCollection AddHomeOfficeIdentity(this IServiceCollection services, IConfiguration config, IHostEnvironment environment, bool generatingContract)
    {
        var development = environment.IsDevelopment() || environment.IsEnvironment("Testing");
        services.AddIdentityApiEndpoints<IdentityUser>(options =>
        {
            options.User.RequireUniqueEmail = true;
            options.SignIn.RequireConfirmedEmail = true;
            options.Password.RequiredLength = 12;
            options.Lockout.MaxFailedAccessAttempts = 5;
            options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
        }).AddEntityFrameworkStores<HomeOfficeDbContext>();
        services.Configure<DataProtectionTokenProviderOptions>(o => o.TokenLifespan = TimeSpan.FromHours(1));
        services.Configure<SecurityStampValidatorOptions>(o => o.ValidationInterval = TimeSpan.Zero);
        services.AddOptions<BearerTokenOptions>(IdentityConstants.BearerScheme).Configure<TimeProvider>((o, time) =>
        {
            o.TimeProvider = time;
            o.BearerTokenExpiration = TimeSpan.FromSeconds(development ? config.GetValue("Auth:AccessTokenSeconds", 900) : 900);
            o.RefreshTokenExpiration = TimeSpan.FromSeconds(development ? config.GetValue("Auth:RefreshTokenSeconds", 604800) : 604800);
        });
        services.ConfigureApplicationCookie(o =>
        {
            o.Cookie.Name = "HomeOffice.Session";
            o.Cookie.HttpOnly = true;
            o.Cookie.SecurePolicy = development ? CookieSecurePolicy.SameAsRequest : CookieSecurePolicy.Always;
            o.Cookie.SameSite = SameSiteMode.Lax;
            o.ExpireTimeSpan = TimeSpan.FromSeconds(development ? config.GetValue("Auth:CookieSeconds", 28800) : 28800);
            o.SlidingExpiration = false;
            o.Events.OnValidatePrincipal = async context =>
            {
                await SecurityStampValidator.ValidatePrincipalAsync(context);
                // Stamp validation normally requests cookie renewal; keep the original absolute expiry.
                context.ShouldRenew = false;
            };
            o.Events.OnRedirectToLogin = context => { context.Response.StatusCode = 401; return Task.CompletedTask; };
            o.Events.OnRedirectToAccessDenied = context => { context.Response.StatusCode = 403; return Task.CompletedTask; };
        });
        services.AddAntiforgery(o =>
        {
            o.HeaderName = "X-CSRF-TOKEN";
            o.Cookie.Name = "HomeOffice.Csrf";
            o.Cookie.HttpOnly = true;
            o.Cookie.SameSite = SameSiteMode.Strict;
            o.Cookie.SecurePolicy = development ? CookieSecurePolicy.SameAsRequest : CookieSecurePolicy.Always;
        });
        services.AddAuthorization();
        services.AddScoped<IMemberDirectory, MemberDirectory>();
        services.AddScoped<AccountProvisioner>();
        services.AddScoped<OwnerProvisioner>();
        services.AddScoped<IAccountEmail, AccountEmail>();
        services.AddRateLimiter(options =>
        {
            options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
            options.AddPolicy("account", context => RateLimitPartition.GetFixedWindowLimiter(
                context.Connection.RemoteIpAddress?.ToString() ?? "unknown", _ => new FixedWindowRateLimiterOptions
                {
                    PermitLimit = development ? config.GetValue("Auth:RequestsPerMinute", 30) : 30,
                    Window = TimeSpan.FromMinutes(1),
                    QueueLimit = 0,
                    AutoReplenishment = true
                }));
        });
        if (generatingContract)
        {
            // Official build-time OpenAPI host: no listener, account operations, private config or persisted keys.
            services.AddDataProtection().UseEphemeralDataProtectionProvider();
            return services;
        }
        var keys = config["DataProtection:KeyDirectory"] ?? Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "HomeOfficeReservation", "keys");
        var protection = services.AddDataProtection().SetApplicationName("HomeOfficeReservation." + environment.EnvironmentName)
            .PersistKeysToFileSystem(new DirectoryInfo(keys));
        var certificatePath = config["DataProtection:CertificatePath"];
        if (!string.IsNullOrEmpty(certificatePath))
            protection.ProtectKeysWithCertificate(X509CertificateLoader.LoadPkcs12FromFile(certificatePath, config["DataProtection:CertificatePassword"]));
        else if (development && OperatingSystem.IsWindows()) protection.ProtectKeysWithDpapi();
        // The real host fails closed if encrypted persistence/production delivery is missing.
        services.AddOptions<IdentityRuntimeRequirements>().Configure(o => o.Configured =
            development && OperatingSystem.IsWindows() || !string.IsNullOrEmpty(certificatePath))
            .Validate(o => o.Configured, "Configure a private Data Protection certificate (see scripts/init_auth.py).").ValidateOnStart();
        if (!development)
        {
            services.AddOptions<ProductionIdentityRequirements>().Configure(o => o.Configured =
                !string.IsNullOrWhiteSpace(config["DataProtection:KeyDirectory"]) &&
                !string.IsNullOrWhiteSpace(config["Email:Host"]) && !string.IsNullOrWhiteSpace(config["Email:From"]) &&
                !string.IsNullOrWhiteSpace(config["Email:Username"]) && !string.IsNullOrWhiteSpace(config["Email:Password"]))
                .Validate(o => o.Configured, "Production requires persistent encrypted keys and configured STARTTLS email delivery.").ValidateOnStart();
        }
        return services;
    }
}

public sealed class IdentityRuntimeRequirements { public bool Configured { get; set; } }
public sealed class ProductionIdentityRequirements { public bool Configured { get; set; } }
