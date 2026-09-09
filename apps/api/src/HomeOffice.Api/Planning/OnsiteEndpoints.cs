using HomeOffice.Application.Planning;
using HomeOffice.Domain.Access;
using HomeOffice.Domain.Planning;
using Microsoft.AspNetCore.Mvc;

namespace HomeOffice.Api.Planning;

internal static class OnsiteEndpoints
{
    private static Guid Actor(HttpContext c) => ((Member)c.Items[typeof(Member)]!).Id;
    public static void Map(RouteGroupBuilder reads, RouteGroupBuilder writes)
    {
        reads.MapGet("/onsite-preview", (Guid employeeId, DateOnly from, DateOnly to, string location, HttpContext c, IPlanningService s, CancellationToken ct, Guid? excludes = null) =>
            s.PreviewOnsite(Actor(c), employeeId, from, to, location, excludes, ct)).WithName("PreviewOnsiteRequirement");
        reads.MapGet("/requirements", (Guid employeeId, HttpContext c, IPlanningService s, CancellationToken ct, int offset = 0, int limit = 25, OnsiteState? state = null) =>
            s.Requirements(Actor(c), employeeId, offset, limit, state, ct)).WithName("ListOnsiteRequirements");
        reads.MapGet("/requirements/{requirementId:guid}", (Guid employeeId, Guid requirementId, HttpContext c, IPlanningService s, CancellationToken ct) =>
            s.Requirement(Actor(c), employeeId, requirementId, ct)).WithName("GetOnsiteRequirement");
        writes.MapPost("/requirements", (Guid employeeId, OnsiteInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) =>
            s.SaveRequirement(Actor(c), employeeId, null, input, idempotencyKey, ct)).WithName("CreateOnsiteRequirement");
        writes.MapPut("/requirements/{requirementId:guid}", (Guid employeeId, Guid requirementId, OnsiteInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) =>
            s.SaveRequirement(Actor(c), employeeId, requirementId, input, idempotencyKey, ct)).WithName("EditOnsiteRequirement");
        writes.MapPost("/requirements/{requirementId:guid}/cancel", (Guid employeeId, Guid requirementId, WorkVersionInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) =>
            s.CancelRequirement(Actor(c), employeeId, requirementId, input, idempotencyKey, ct)).WithName("CancelOnsiteRequirement");
        writes.MapPost("/requirements/{requirementId:guid}/acknowledge", (Guid employeeId, Guid requirementId, OnsiteAcknowledgeInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) =>
            s.AcknowledgeRequirement(Actor(c), employeeId, requirementId, input, idempotencyKey, ct)).WithName("AcknowledgeOnsiteRequirement");
        reads.MapGet("/tasks", (Guid employeeId, HttpContext c, IPlanningService s, CancellationToken ct, int offset = 0, int limit = 25, AssignedTaskState? state = null) =>
            s.Tasks(Actor(c), employeeId, offset, limit, state, ct)).WithName("ListAssignedTasks");
        reads.MapGet("/tasks/{taskId:guid}", (Guid employeeId, Guid taskId, HttpContext c, IPlanningService s, CancellationToken ct) =>
            s.TaskDetail(Actor(c), employeeId, taskId, ct)).WithName("GetAssignedTask");
        writes.MapPost("/tasks", (Guid employeeId, TaskInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) =>
            s.SaveTask(Actor(c), employeeId, null, input, idempotencyKey, ct)).WithName("CreateAssignedTask");
        writes.MapPut("/tasks/{taskId:guid}", (Guid employeeId, Guid taskId, TaskInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) =>
            s.SaveTask(Actor(c), employeeId, taskId, input, idempotencyKey, ct)).WithName("EditAssignedTask");
        writes.MapPost("/tasks/{taskId:guid}/progress", (Guid employeeId, Guid taskId, TaskProgressInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) =>
            s.TaskProgress(Actor(c), employeeId, taskId, input, idempotencyKey, ct)).WithName("UpdateTaskProgress");
        reads.MapGet("/work/{kind}/{contextId:guid}/entries", (Guid employeeId, WorkContext kind, Guid contextId, HttpContext c, IPlanningService s, CancellationToken ct, int offset = 0, int limit = 25) =>
            s.WorkEntries(Actor(c), employeeId, kind, contextId, offset, limit, ct)).WithName("ListWorkEntries");
        writes.MapPost("/work/{kind}/{contextId:guid}/comments", (Guid employeeId, WorkContext kind, Guid contextId, WorkCommentInput input, [FromHeader(Name = "Idempotency-Key")] string idempotencyKey, HttpContext c, IPlanningService s, CancellationToken ct) =>
            s.WorkComment(Actor(c), employeeId, kind, contextId, input, idempotencyKey, ct)).WithName("AddWorkComment");
    }
}
