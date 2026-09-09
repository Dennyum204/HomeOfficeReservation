using HomeOffice.Application.Planning;
using HomeOffice.Domain.Planning;
using Microsoft.EntityFrameworkCore;
using static HomeOffice.Domain.Planning.PlanningRules;

namespace HomeOffice.Infrastructure.Planning;

public sealed partial class PlanningService
{
    private async Task<AssignedTask> LoadTask(Guid employee, Guid id, CancellationToken ct)
    {
        var task = await db.Set<AssignedTask>().SingleOrDefaultAsync(x => x.EmployeeId == employee && x.Id == id, ct);
        Require(task is not null, "task_not_found", 404); return task!;
    }
    private async Task<TaskView> TaskViewOf(AssignedTask t, CancellationToken ct)
    {
        var requirement = t.RequirementId is { } id ? await LoadRequirement(t.EmployeeId, id, ct) : null;
        return new(t.Id, t.EmployeeId, t.Title, t.Description, t.Deadline, t.State, t.RequiresOnsite,
            t.RequirementId, requirement?.State, requirement?.Revision, t.ProgressNote, t.Version);
    }
    public Task<TaskPage> Tasks(Guid actor, Guid employee, int offset, int limit, AssignedTaskState? state, CancellationToken ct) => Read(actor, employee, async () =>
    {
        Page(offset, limit); Require(state is null || Enum.IsDefined(state.Value), "invalid_task_state", 400);
        var rows = await db.Set<AssignedTask>().Where(x => x.EmployeeId == employee && (state == null || x.State == state))
            .OrderBy(x => x.Deadline).ThenBy(x => x.Id).Skip(offset).Take(limit + 1).ToArrayAsync(ct);
        var views = new List<TaskView>(); foreach (var r in rows.Take(limit)) views.Add(await TaskViewOf(r, ct));
        return new TaskPage(views.ToArray(), rows.Length > limit ? offset + limit : null, await CalendarVersion(employee, ct));
    }, ct);
    public Task<TaskView> TaskDetail(Guid actor, Guid employee, Guid id, CancellationToken ct) => Read(actor, employee, async () => await TaskViewOf(await LoadTask(employee, id, ct), ct), ct);

    public Task<MutationReceipt> SaveTask(Guid actor, Guid employee, Guid? id, TaskInput input, string key, CancellationToken ct) =>
        Mutate(actor, employee, Permission.Manager, id is null ? "task.assigned" : "task.updated", id, input, key, input.ExpectedCalendarVersion, async p =>
        {
            Text(input.Title, 200, true); Text(input.Description, 2000); Require(Enum.IsDefined(input.State), "invalid_task_state", 400);
            AssignedTask task;
            if (id is { } existing) { task = await LoadTask(employee, existing, ct); Version(input.ExpectedVersion, task.Version); task.Version++; }
            else { task = new() { OrganizationId = p.OrganizationId, EmployeeId = employee, CreatedAt = clock.GetUtcNow() }; db.Set<AssignedTask>().Add(task); }
            if (id is null || task.Deadline != input.Deadline) Dates([input.Deadline], await Today(p.OrganizationId, ct));
            if (input.RequirementId is { } requirementId)
            {
                var requirement = await LoadRequirement(employee, requirementId, ct);
                Require(requirement.OrganizationId == p.OrganizationId, "forbidden", 403);
                // Existing cancelled links remain historical; newly linking a cancelled requirement is invalid.
                Require(task.RequirementId == requirementId || requirement.State != OnsiteState.Cancelled, "requirement_cancelled");
            }
            task.Title = input.Title.Trim(); task.Description = input.Description.Trim(); task.Deadline = input.Deadline;
            task.State = input.State; task.RequiresOnsite = input.RequiresOnsite; task.RequirementId = input.RequirementId;
            WorkHistory(p, actor, WorkContext.Task, task.Id, id is null ? "task.assigned" : "task.updated", task);
            return (task.Id, task.Version);
        }, ct);

    public Task<MutationReceipt> TaskProgress(Guid actor, Guid employee, Guid id, TaskProgressInput input, string key, CancellationToken ct) =>
        Mutate(actor, employee, Permission.Employee, "task.progress", id, input, key, input.ExpectedCalendarVersion, async p =>
        {
            var task = await LoadTask(employee, id, ct); Version(input.ExpectedVersion, task.Version);
            Text(input.Note, 1000); Require(Enum.IsDefined(input.State) && input.State != AssignedTaskState.Cancelled, "invalid_task_progress", 400);
            Require(task.State is AssignedTaskState.Todo or AssignedTaskState.InProgress, "task_terminal");
            task.State = input.State; task.ProgressNote = input.Note.Trim(); task.Version++;
            WorkHistory(p, actor, WorkContext.Task, id, "task.progress", task);
            return (id, task.Version);
        }, ct);

    private async Task LoadWorkContext(Guid employee, WorkContext kind, Guid id, CancellationToken ct)
    {
        Require(Enum.IsDefined(kind), "invalid_work_context", 400);
        if (kind == WorkContext.Requirement) await LoadRequirement(employee, id, ct); else await LoadTask(employee, id, ct);
    }
    public Task<WorkEntryPage> WorkEntries(Guid actor, Guid employee, WorkContext kind, Guid id, int offset, int limit, CancellationToken ct) => Read(actor, employee, async () =>
    {
        Page(offset, limit); await LoadWorkContext(employee, kind, id, ct);
        var rows = await db.Set<WorkEntry>().Where(x => x.EmployeeId == employee && (kind == WorkContext.Requirement ? x.RequirementId == id : x.TaskId == id))
            .OrderByDescending(x => x.CreatedAt).ThenBy(x => x.Id).Skip(offset).Take(limit + 1)
            .Select(x => new WorkEntryView(x.Id, x.AuthorId, x.Action, x.Text, x.SnapshotJson, x.CreatedAt, x.CalendarVersion)).ToArrayAsync(ct);
        return new WorkEntryPage(rows.Take(limit).ToArray(), rows.Length > limit ? offset + limit : null);
    }, ct);
    public Task<MutationReceipt> WorkComment(Guid actor, Guid employee, WorkContext kind, Guid id, WorkCommentInput input, string key, CancellationToken ct) =>
        Mutate(actor, employee, Permission.Read, "work.commented", id, new { kind, input }, key, input.ExpectedCalendarVersion, async p =>
        {
            await LoadWorkContext(employee, kind, id, ct); Text(input.Text, 2000, true);
            WorkHistory(p, actor, kind, id, "work.commented", new { }, input.Text.Trim());
            return (id, p.CalendarVersion);
        }, ct);
}
