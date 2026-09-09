using HomeOffice.Api.Access;
using HomeOffice.Application.Planning;
using HomeOffice.Domain.Access;
using HomeOffice.Domain.Planning;
using Microsoft.AspNetCore.Mvc;

namespace HomeOffice.Api.Planning;

public static class PlanningEndpoints
{
    private static Guid Actor(HttpContext c) => ((Member)c.Items[typeof(Member)]!).Id;
    public static void MapPlanning(this WebApplication app)
    {
        var g = app.MapGroup("/api/v1/planning/{employeeId:guid}").WithTags("Planning").RequireAuthorization()
            .AddEndpointFilter<ActiveMemberFilter>().AddEndpointFilter<PlanningErrorFilter>()
            .WithMetadata(new ProducesResponseTypeAttribute(typeof(ProblemDetails), 400), new ProducesResponseTypeAttribute(typeof(ProblemDetails), 403),
                new ProducesResponseTypeAttribute(typeof(ProblemDetails), 404), new ProducesResponseTypeAttribute(typeof(ProblemDetails), 409),
                new ProducesResponseTypeAttribute(typeof(ProblemDetails), 412), new ProducesResponseTypeAttribute(typeof(ProblemDetails), 428));
        g.MapGet("/calendar", (Guid employeeId, DateOnly from, DateOnly to, HttpContext c, IPlanningService s, CancellationToken ct) => s.Calendar(Actor(c), employeeId, from, to, ct)).WithName("GetCalendar");
        g.MapGet("/requests", (Guid employeeId, HttpContext c, IPlanningService s, CancellationToken ct, int offset = 0, int limit = 25, RequestState? state = null) => s.Requests(Actor(c), employeeId, offset, limit, ct, state)).WithName("ListPlanningRequests");
        g.MapGet("/requests/{requestId:guid}", (Guid employeeId, Guid requestId, HttpContext c, IPlanningService s, CancellationToken ct) => s.Request(Actor(c), employeeId, requestId, ct)).WithName("GetPlanningRequest");
        g.MapGet("/requests/{requestId:guid}/proposals", (Guid employeeId, Guid requestId, HttpContext c, IPlanningService s, CancellationToken ct, int offset = 0, int limit = 25) => s.Proposals(Actor(c), employeeId, requestId, offset, limit, ct)).WithName("ListCounterproposals");
        g.MapGet("/requests/{requestId:guid}/comments", (Guid employeeId, Guid requestId, HttpContext c, IPlanningService s, CancellationToken ct, int offset = 0, int limit = 25) => s.Comments(Actor(c), employeeId, requestId, offset, limit, ct)).WithName("ListPlanningComments");
        g.MapGet("/patterns", (Guid employeeId, HttpContext c, IPlanningService s, CancellationToken ct, int offset = 0, int limit = 25) => s.Patterns(Actor(c), employeeId, offset, limit, ct)).WithName("ListWeeklyPatterns");
        var writes = g.MapGroup("").AddEndpointFilter<CsrfFilter>();
        writes.MapPost("/requests", (Guid employeeId, DraftInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) => s.Draft(Actor(c), employeeId, null, input, idempotencyKey, ct)).WithName("CreatePlanningDraft");
        writes.MapPut("/requests/{requestId:guid}/draft", (Guid employeeId, Guid requestId, DraftInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) => s.Draft(Actor(c), employeeId, requestId, input, idempotencyKey, ct)).WithName("EditPlanningDraft");
        writes.MapPost("/requests/{requestId:guid}/submit", (Guid employeeId, Guid requestId, SubmitInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) => s.Submit(Actor(c), employeeId, requestId, input, idempotencyKey, ct)).WithName("SubmitPlanningRequest");
        writes.MapPost("/requests/{requestId:guid}/decide", (Guid employeeId, Guid requestId, DecisionInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) => s.Decide(Actor(c), employeeId, requestId, input, idempotencyKey, ct)).WithName("DecidePlanningDays");
        writes.MapPost("/requests/{requestId:guid}/withdraw", (Guid employeeId, Guid requestId, WithdrawInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) => s.Withdraw(Actor(c), employeeId, requestId, input, idempotencyKey, ct)).WithName("WithdrawPlanningDays");
        writes.MapPost("/requests/{requestId:guid}/proposals", (Guid employeeId, Guid requestId, ProposalInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) => s.Propose(Actor(c), employeeId, requestId, null, input, idempotencyKey, ct)).WithName("CreateCounterproposal");
        writes.MapPut("/requests/{requestId:guid}/proposals/{proposalId:guid}", (Guid employeeId, Guid requestId, Guid proposalId, ProposalInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) => s.Propose(Actor(c), employeeId, requestId, proposalId, input, idempotencyKey, ct)).WithName("ReviseCounterproposal");
        writes.MapPost("/proposals/{proposalId:guid}/accept", (Guid employeeId, Guid proposalId, AcceptProposalInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) => s.Accept(Actor(c), employeeId, proposalId, input, idempotencyKey, ct)).WithName("AcceptCounterproposal");
        writes.MapPost("/patterns", (Guid employeeId, PatternInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) => s.Pattern(Actor(c), employeeId, input, idempotencyKey, ct)).WithName("SetWeeklyPattern");
        writes.MapPost("/requests/{requestId:guid}/comments", (Guid employeeId, Guid requestId, CommentInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) => s.Comment(Actor(c), employeeId, requestId, input, idempotencyKey, ct)).WithName("AddPlanningComment");
        // Date preview has no member/calendar data; explicit dates remain authoritative at submission.
        app.MapGet("/api/v1/planning/date-preview", (DateOnly from, DateOnly to, bool includeWeekends = false) =>
            new DatePreview(PlanningRules.Expand(from, to, includeWeekends).Select(d => new PreviewDay(d,
                d.DayOfWeek is DayOfWeek.Saturday or DayOfWeek.Sunday)).ToArray())).RequireAuthorization().AddEndpointFilter<ActiveMemberFilter>()
            .AddEndpointFilter<PlanningErrorFilter>().WithTags("Planning").WithName("PreviewPlanningDates");
    }
}

public sealed class PlanningErrorFilter : IEndpointFilter
{
    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        try { return await next(context); }
        catch (PlanningException e)
        { return Results.Problem(statusCode: e.Status, title: e.Code, extensions: new Dictionary<string, object?> { ["code"] = e.Code }); }
    }
}
