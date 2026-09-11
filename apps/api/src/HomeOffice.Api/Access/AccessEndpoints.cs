using System.Security.Claims;
using HomeOffice.Application.Access;
using HomeOffice.Domain.Access;
using HomeOffice.Infrastructure.Access;
using HomeOffice.Infrastructure.Persistence;
using Microsoft.AspNetCore.Antiforgery;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.BearerToken;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace HomeOffice.Api.Access;

public sealed record Credentials(string Email, string Password);
public sealed record EmailRequest(string Email);
public sealed record CompleteAccountRequest(string Email, string Code, string Password);
public sealed record CsrfToken(string RequestToken);

public static class AccessEndpoints
{
    public static void MapAccess(this WebApplication app)
    {
        var auth = app.MapGroup("/api/v1/auth").WithTags("Auth").RequireRateLimiting("account");
        auth.MapGet("/csrf", (HttpContext context, IAntiforgery csrf) =>
        {
            context.Response.Headers.CacheControl = "no-store";
            return TypedResults.Ok(new CsrfToken(csrf.GetAndStoreTokens(context).RequestToken!));
        }).WithName("GetCsrfToken");
        auth.MapPost("/web/login", (Credentials request, HttpContext context, SignInManager<IdentityUser> signIn,
            UserManager<IdentityUser> users, IMemberDirectory members) => Login(request, context, signIn, users, members, true))
            .AddEndpointFilter<CsrfFilter>().Produces(204).ProducesProblem(401).WithName("LoginWeb");
        auth.MapPost("/token/login", (Credentials request, HttpContext context, SignInManager<IdentityUser> signIn,
            UserManager<IdentityUser> users, IMemberDirectory members) => Login(request, context, signIn, users, members, false))
            .Produces<AccessTokenResponse>().ProducesProblem(401).WithName("LoginToken");
        auth.MapPost("/token/refresh", Refresh).Produces<AccessTokenResponse>().ProducesProblem(401).WithName("RefreshSession");
        auth.MapPost("/logout", async (HttpContext context) =>
        {
            await context.SignOutAsync(IdentityConstants.ApplicationScheme);
            return TypedResults.NoContent();
        }).AddEndpointFilter<CsrfFilter>().WithName("Logout");
        // Anonymous JSON operations use explicit single-purpose Identity tokens, not ambient cookie authority.
        auth.MapPost("/activation/request", async (EmailRequest request, InvitationService invitations, InvitationDelivery delivery) =>
        {
            var memberId = await invitations.RequestAnonymous(request.Email);
            if (memberId is not null) await delivery.TryNow(memberId.Value);
            return Results.Accepted();
        })
            .Produces(202).WithName("RequestActivation");
        auth.MapPost("/recovery/request", (EmailRequest request, UserManager<IdentityUser> users,
            IMemberDirectory members, IAccountEmail email) => SendCode(request, users, members, email, false))
            .Produces(202).WithName("RequestRecovery");
        auth.MapPost("/activation/complete", async (CompleteAccountRequest request, InvitationService invitations) =>
            await invitations.Complete(request.Email, request.Code, request.Password) ? Results.NoContent() :
                Results.Problem(statusCode: 400, title: "invalid_code_or_password"))
            .Produces(204).ProducesProblem(400).WithName("ActivateAccount");
        auth.MapPost("/recovery/complete", (CompleteAccountRequest request, UserManager<IdentityUser> users,
            HomeOfficeDbContext db) => Complete(request, users, db, false)).Produces(204).ProducesProblem(400).WithName("ResetPassword");

        var access = app.MapGroup("/api/v1").WithTags("Access").RequireAuthorization().AddEndpointFilter<ActiveMemberFilter>();
        access.MapGet("/me", async (HttpContext context, IMemberDirectory members) =>
            TypedResults.Ok((await members.ProfileAsync(Actor(context), Actor(context).Id))!)).WithName("GetCurrentMember");
        access.MapGet("/members", (HttpContext context, IMemberDirectory members) => members.ListAsync(Actor(context))).WithName("ListMembers");
        access.MapGet("/members/{memberId:guid}", async (Guid memberId, HttpContext context, IMemberDirectory members) =>
        {
            var member = await members.ProfileAsync(Actor(context), memberId);
            return member is null ? Results.Problem(statusCode: 403, title: "forbidden") : Results.Ok(member);
        }).Produces<MemberProfile>().ProducesProblem(403).WithName("GetMember");
        access.MapGet("/members/{memberId:guid}/management-access", async (Guid memberId, HttpContext context, IMemberDirectory members) =>
        {
            var member = await members.ProfileAsync(Actor(context), memberId, managementOnly: true);
            return member is null ? Results.Problem(statusCode: 403, title: "forbidden") : Results.Ok(member);
        }).Produces<MemberProfile>().ProducesProblem(403).WithName("CheckManagementAccess")
            .WithSummary("Read-only relationship/role guard. Does not create or approve any request.");
        access.MapPost("/admin/members", async (ProvisionMemberRequest request, HttpContext context, AccountProvisioner provisioner) =>
            Operation(await provisioner.ProvisionAsync(Actor(context), request))).AddEndpointFilter<CsrfFilter>()
            .RequireRateLimiting("account").Produces(204).ProducesProblem(403).ProducesProblem(400).ProducesProblem(429).WithName("ProvisionMember")
            .WithSummary("Create an admitted member and durable invitation. Repeating the identical normalized request by the same administrator returns success without creating or resending.");
        access.MapGet("/admin/invitations", async (Guid? after, int? limit, HttpContext context, InvitationService invitations) =>
        {
            var page = await invitations.List(Actor(context), after, limit ?? 50);
            return page is null ? Results.Problem(statusCode: 403, title: "forbidden_or_invalid_page") : Results.Ok(page);
        }).Produces<InvitationPage>().ProducesProblem(403).WithName("ListInvitations");
        access.MapPost("/admin/members/{memberId:guid}/invitation/resend", async (Guid memberId, InvitationChangeRequest request,
            HttpContext context, InvitationService invitations, InvitationDelivery delivery) =>
        {
            var result = await invitations.Change(Actor(context), memberId, request, cancel: false);
            if (result.Succeeded && result.Code != "already_applied") await delivery.TryNow(memberId);
            return Operation(result);
        }).AddEndpointFilter<CsrfFilter>().RequireRateLimiting("account").Produces(204).ProducesProblem(400).ProducesProblem(403)
            .ProducesProblem(409).ProducesProblem(429).WithName("ResendInvitation");
        access.MapPost("/admin/members/{memberId:guid}/invitation/cancel", async (Guid memberId, InvitationChangeRequest request,
            HttpContext context, InvitationService invitations) => Operation(await invitations.Change(Actor(context), memberId, request, cancel: true)))
            .AddEndpointFilter<CsrfFilter>().RequireRateLimiting("account").Produces(204).ProducesProblem(400).ProducesProblem(403)
            .ProducesProblem(409).WithName("CancelInvitation");
        access.MapPut("/admin/members/{memberId:guid}", async (Guid memberId, UpdateMemberRequest request, HttpContext context, IMemberDirectory members) =>
            Operation(await members.UpdateAsync(Actor(context), memberId, request))).AddEndpointFilter<CsrfFilter>()
            .Produces(204).ProducesProblem(403).ProducesProblem(400).ProducesProblem(409).WithName("UpdateMember");
        access.MapPut("/admin/members/{employeeId:guid}/manager", async (Guid employeeId, SetManagerRequest request, HttpContext context, IMemberDirectory members) =>
            Operation(await members.AssignManagerAsync(Actor(context), employeeId, request.ManagerId, request.ExpectedAccessVersion, request.CommandId))).AddEndpointFilter<CsrfFilter>()
            .Produces(204).ProducesProblem(403).ProducesProblem(400).ProducesProblem(409).WithName("AssignManager");
    }

    private static IResult Operation(OperationResult result) => result.Succeeded ? Results.NoContent() :
        Results.Problem(statusCode: result.Code switch
        {
            "forbidden" => 403,
            "resend_limited" or "invitation_limit" => 429,
            "stale_member" or "stale_invitation" or "idempotency_conflict" => 409,
            _ => 400
        }, title: result.Code);

    private static Member Actor(HttpContext context) => (Member)context.Items[typeof(Member)]!;

    private static async Task<IResult> Login(Credentials request, HttpContext context, SignInManager<IdentityUser> signIn,
        UserManager<IdentityUser> users, IMemberDirectory members, bool cookie)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || request.Email.Length > 254 ||
            string.IsNullOrEmpty(request.Password) || request.Password.Length > 512) return InvalidLogin();
        var user = await users.FindByEmailAsync(request.Email);
        var member = user is null ? null : await members.CurrentAsync(user.Id);
        if (user is null || member?.Active != true) return InvalidLogin();
        // SignInManager and the built-in cookie/bearer handler issue the response; no application token format.
        signIn.AuthenticationScheme = cookie ? IdentityConstants.ApplicationScheme : IdentityConstants.BearerScheme;
        var result = await signIn.PasswordSignInAsync(user, request.Password, isPersistent: cookie, lockoutOnFailure: true);
        if (!result.Succeeded) return InvalidLogin();
        return cookie ? Results.NoContent() : Results.Empty;
    }

    private static IResult InvalidLogin() => Results.Problem(statusCode: 401, title: "invalid_credentials");

    private static async Task<IResult> Refresh(RefreshRequest request, IOptionsMonitor<BearerTokenOptions> options,
        TimeProvider clock, SignInManager<IdentityUser> signIn, IMemberDirectory members)
    {
        if (string.IsNullOrEmpty(request.RefreshToken) || request.RefreshToken.Length > 16384) return InvalidLogin();
        // Mirrors the framework's refresh checks using its own purpose-separated ticket protector.
        var ticket = options.Get(IdentityConstants.BearerScheme).RefreshTokenProtector.Unprotect(request.RefreshToken);
        if (ticket?.Properties.ExpiresUtc is not { } expires || clock.GetUtcNow() >= expires ||
            await signIn.ValidateSecurityStampAsync(ticket.Principal) is not IdentityUser user ||
            (await members.CurrentAsync(user.Id))?.Active != true) return InvalidLogin();
        return Results.SignIn(await signIn.CreateUserPrincipalAsync(user), authenticationScheme: IdentityConstants.BearerScheme);
    }

    private static async Task<IResult> SendCode(EmailRequest request, UserManager<IdentityUser> users,
        IMemberDirectory members, IAccountEmail email, bool activation)
    {
        if (!string.IsNullOrWhiteSpace(request.Email) && request.Email.Length <= 254)
        {
            var user = await users.FindByEmailAsync(request.Email);
            if (user is not null && (await members.CurrentAsync(user.Id))?.Active == true && user.EmailConfirmed != activation)
            {
                var code = activation ? await users.GenerateEmailConfirmationTokenAsync(user) : await users.GeneratePasswordResetTokenAsync(user);
                try { await email.SendAsync(user.Email!, activation ? "activate" : "recover", code); }
                catch (EmailDeliveryException) { /* Same public response; delivery failure is logged without recipient/token. */ }
            }
        }
        return Results.Accepted(); // Same body/status for unknown, inactive and eligible accounts.
    }

    private static async Task<IResult> Complete(CompleteAccountRequest request, UserManager<IdentityUser> users,
        HomeOfficeDbContext db, bool activation)
    {
        IResult Invalid() => Results.Problem(statusCode: 400, title: "invalid_code_or_password");
        if (string.IsNullOrWhiteSpace(request.Email) || request.Email.Length > 254 ||
            string.IsNullOrEmpty(request.Code) || request.Code.Length > 16384 ||
            string.IsNullOrEmpty(request.Password) || request.Password.Length > 512) return Invalid();
        var user = await users.FindByEmailAsync(request.Email);
        if (user is null || !await db.Members.AnyAsync(m => m.IdentityUserId == user.Id && m.Active) || user.EmailConfirmed == activation) return Invalid();
        await using var transaction = await db.Database.BeginTransactionAsync();
        IdentityResult result;
        if (activation)
        {
            if (await users.HasPasswordAsync(user)) return Invalid();
            result = await users.ConfirmEmailAsync(user, request.Code);
            if (!result.Succeeded) return Invalid();
            result = await users.AddPasswordAsync(user, request.Password);
        }
        else result = await users.ResetPasswordAsync(user, request.Code, request.Password);
        if (!result.Succeeded) return Invalid();
        await transaction.CommitAsync();
        return Results.NoContent();
    }
}

public sealed class ActiveMemberFilter : IEndpointFilter
{
    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        var identityId = context.HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
        var directory = context.HttpContext.RequestServices.GetRequiredService<IMemberDirectory>();
        var member = identityId is null ? null : await directory.CurrentAsync(identityId);
        if (member?.Active != true) return Results.Problem(statusCode: 403, title: "inactive_membership");
        context.HttpContext.Items[typeof(Member)] = member;
        context.HttpContext.Response.Headers.CacheControl = "no-store";
        return await next(context);
    }
}

public sealed class CsrfFilter : IEndpointFilter
{
    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        // An arbitrary Authorization header never bypasses CSRF: the bearer must authenticate successfully.
        var bearer = await context.HttpContext.AuthenticateAsync(IdentityConstants.BearerScheme);
        if (!bearer.Succeeded || context.HttpContext.Request.Path == "/api/v1/auth/web/login")
        {
            try { await context.HttpContext.RequestServices.GetRequiredService<IAntiforgery>().ValidateRequestAsync(context.HttpContext); }
            catch (AntiforgeryValidationException) { return Results.Problem(statusCode: 400, title: "csrf_required"); }
        }
        return await next(context);
    }
}
