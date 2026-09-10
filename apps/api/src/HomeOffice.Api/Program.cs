using HomeOffice.Application.Workspace;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi;
using HomeOffice.Api.Access;
using System.Text.Json.Serialization;
using HomeOffice.Application.Planning;
using HomeOffice.Infrastructure.Planning;
using HomeOffice.Api.Planning;
using HomeOffice.Api.Notifications;
using HomeOffice.Api;

var builder = WebApplication.CreateBuilder(args);
var generatingContract = System.Reflection.Assembly.GetEntryAssembly()?.GetName().Name == "GetDocument.Insider";
if (!generatingContract && builder.Environment.IsDevelopment())
    builder.Configuration.AddJsonFile("appsettings.Local.json", optional: true, reloadOnChange: false).AddEnvironmentVariables();
if (!generatingContract && Environment.GetEnvironmentVariable("HO_CONFIG_FILE") is { } privateConfig)
{
    if (!Path.IsPathFullyQualified(privateConfig)) throw new InvalidOperationException("HO_CONFIG_FILE must be an absolute private file path.");
    builder.Configuration.AddJsonFile(privateConfig, optional: false, reloadOnChange: false).AddEnvironmentVariables();
}
ProductionHosting.Configure(builder.Services, builder.Configuration, builder.Environment, generatingContract);
builder.Services.AddProblemDetails();
builder.Services.AddSingleton(TimeProvider.System);
builder.Services.ConfigureHttpJsonOptions(o => o.SerializerOptions.UnmappedMemberHandling = JsonUnmappedMemberHandling.Disallow);
builder.Services.ConfigureHttpJsonOptions(o => o.SerializerOptions.Converters.Add(new JsonStringEnumConverter()));
builder.Services.ConfigureHttpJsonOptions(o => o.SerializerOptions.NumberHandling = JsonNumberHandling.Strict);
builder.Services.AddScoped<IPlanningService, PlanningService>();
builder.Services.AddHomeOfficeIdentity(builder.Configuration, builder.Environment, generatingContract);
builder.Services.AddNotifications(builder.Configuration, builder.Environment, generatingContract);
builder.Services.AddScoped<GetWorkspaceInfo>();
builder.Services.AddDbContext<HomeOfficeDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("Database")));
builder.Services.AddHealthChecks().AddCheck<DatabaseHealthCheck>("postgresql", tags: ["ready"]);
builder.Services.AddOpenApi("v1", options =>
{
    options.OpenApiVersion = OpenApiSpecVersion.OpenApi3_0;
    options.AddDocumentTransformer((document, _, _) =>
    {
        document.Info.Title = "HomeOfficeReservation API";
        document.Info.Version = "v1";
        document.Servers = [];
        return Task.CompletedTask;
    });
});

var app = builder.Build();
if (!generatingContract && await MaintenanceCommands.ExecuteAsync(args, app)) return;
app.UseExceptionHandler();
app.UseStatusCodePages();
if (!app.Environment.IsDevelopment() && !app.Environment.IsEnvironment("Testing"))
{
    app.UseForwardedHeaders();
    app.UseHsts();
    app.Use(async (context, next) =>
    {
        if (!context.Request.IsHttps && context.Request.Path.StartsWithSegments("/api"))
        { context.Response.StatusCode = 400; return; }
        await next(context);
    });
}
if (Directory.Exists(app.Environment.WebRootPath))
{
    app.UseDefaultFiles();
    app.UseStaticFiles();
}
app.UseAuthentication();
app.UseAuthorization();
app.UseRateLimiter();
app.MapAccess();
app.MapPlanning();
app.MapNotifications();
app.MapHealthChecks("/health/live", new HealthCheckOptions { Predicate = _ => false });
app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready")
});
app.MapGet("/api/v1/workspace", (GetWorkspaceInfo query) => TypedResults.Ok(query.Execute()))
    .WithName("GetWorkspaceInfo").WithTags("Workspace")
    .WithSummary("Public workspace metadata and a fresh server timestamp; no personal data.");
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}
// Deliberate client routes only: an unknown /api path must remain a real 404.
if (Directory.Exists(app.Environment.WebRootPath))
    foreach (var route in new[] { "/calendar", "/requests", "/onsite", "/tasks", "/notifications", "/settings" })
        app.MapFallbackToFile(route, "index.html").ExcludeFromDescription();
app.Run();

public partial class Program;
