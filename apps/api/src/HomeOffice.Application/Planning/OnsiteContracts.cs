using HomeOffice.Domain.Planning;

namespace HomeOffice.Application.Planning;

public sealed record OnsiteInput(long? ExpectedCalendarVersion, long? ExpectedVersion, DateOnly From, DateOnly To,
    string Reason, string Location, string Reference);
public sealed record WorkVersionInput(long? ExpectedCalendarVersion, long? ExpectedVersion);
public sealed record OnsiteAcknowledgeInput(long? ExpectedCalendarVersion, long? ExpectedVersion, int Revision);
public sealed record OnsiteView(Guid Id, Guid EmployeeId, DateOnly From, DateOnly To, string Reason, string Location,
    string Reference, OnsiteState State, int Revision, long Version, DateTimeOffset? ReadAt);
public sealed record OnsitePage(OnsiteView[] Items, int? NextOffset, long CalendarVersion);
public sealed record OnsiteConflict(DateOnly LocalDate, string Code, Guid ContextId, Guid? RequestId);
public sealed record OnsitePreview(long CalendarVersion, OnsiteState Result, OnsiteConflict[] Conflicts);
public sealed record TaskInput(long? ExpectedCalendarVersion, long? ExpectedVersion, string Title, string Description,
    DateOnly Deadline, AssignedTaskState State, bool RequiresOnsite, Guid? RequirementId);
public sealed record TaskProgressInput(long? ExpectedCalendarVersion, long? ExpectedVersion, AssignedTaskState State, string Note);
public sealed record TaskView(Guid Id, Guid EmployeeId, string Title, string Description, DateOnly Deadline,
    AssignedTaskState State, bool RequiresOnsite, Guid? RequirementId, OnsiteState? RequirementState,
    int? RequirementRevision, string ProgressNote, long Version);
public sealed record TaskPage(TaskView[] Items, int? NextOffset, long CalendarVersion);
public sealed record WorkEntryView(Guid Id, Guid AuthorId, string Action, string Text, string SnapshotJson,
    DateTimeOffset CreatedAt, long CalendarVersion);
public sealed record WorkEntryPage(WorkEntryView[] Items, int? NextOffset);
public sealed record WorkCommentInput(long? ExpectedCalendarVersion, string Text);

public partial interface IPlanningService
{
    Task<OnsitePreview> PreviewOnsite(Guid actor, Guid employee, DateOnly from, DateOnly to, string location, Guid? excludes, CancellationToken ct);
    Task<OnsitePage> Requirements(Guid actor, Guid employee, int offset, int limit, OnsiteState? state, CancellationToken ct);
    Task<OnsiteView> Requirement(Guid actor, Guid employee, Guid id, CancellationToken ct);
    Task<MutationReceipt> SaveRequirement(Guid actor, Guid employee, Guid? id, OnsiteInput input, string key, CancellationToken ct);
    Task<MutationReceipt> CancelRequirement(Guid actor, Guid employee, Guid id, WorkVersionInput input, string key, CancellationToken ct);
    Task<MutationReceipt> AcknowledgeRequirement(Guid actor, Guid employee, Guid id, OnsiteAcknowledgeInput input, string key, CancellationToken ct);
    Task<TaskPage> Tasks(Guid actor, Guid employee, int offset, int limit, AssignedTaskState? state, CancellationToken ct);
    Task<TaskView> TaskDetail(Guid actor, Guid employee, Guid id, CancellationToken ct);
    Task<MutationReceipt> SaveTask(Guid actor, Guid employee, Guid? id, TaskInput input, string key, CancellationToken ct);
    Task<MutationReceipt> TaskProgress(Guid actor, Guid employee, Guid id, TaskProgressInput input, string key, CancellationToken ct);
    Task<WorkEntryPage> WorkEntries(Guid actor, Guid employee, WorkContext kind, Guid id, int offset, int limit, CancellationToken ct);
    Task<MutationReceipt> WorkComment(Guid actor, Guid employee, WorkContext kind, Guid id, WorkCommentInput input, string key, CancellationToken ct);
}
