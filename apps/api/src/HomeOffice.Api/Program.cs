using HomeOffice.Application.Workspace;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi;

var builder = WebApplication.CreateBuilder(args);
builder.Configuration.AddJsonFile("appsettings.Local.json", optional: true, reloadOnChange: false)
    .AddEnvironmentVariables();
builder.Services.AddProblemDetails();
builder.Services.AddSingleton(TimeProvider.System);
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
app.UseExceptionHandler();
app.UseStatusCodePages();
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
app.Run();

public partial class Program;
