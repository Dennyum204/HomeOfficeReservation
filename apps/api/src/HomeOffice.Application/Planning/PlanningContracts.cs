using HomeOffice.Domain.Planning;

namespace HomeOffice.Application.Planning;

public sealed record DayInput(DateOnly LocalDate, WorkLocation Location, Availability Availability,
    bool Cancel = false, Guid? BaseDayId = null, long? BasePlanVersion = null);
public sealed record DraftInput(long? ExpectedCalendarVersion, long? ExpectedRequestVersion, Guid? ParentRevisionId,
    string Note, DayInput[] Days);
public sealed record SubmitInput(long? ExpectedCalendarVersion, long? ExpectedRequestVersion);
public sealed record SelectedDay(Guid DayId, long? ExpectedVersion);
public sealed record DecisionInput(long? ExpectedCalendarVersion, long? ExpectedRequestVersion,
    SelectedDay[] Days, bool Approve, string? Reason);
public sealed record WithdrawInput(long? ExpectedCalendarVersion, long? ExpectedRequestVersion, SelectedDay[] Days);
public sealed record ProposalInput(long? ExpectedCalendarVersion, long? ExpectedRequestVersion,
    SelectedDay[] AffectedDays, DayInput[] Days, string Reason, Guid? RequirementId = null, int? RequirementRevision = null);
public sealed record AcceptProposalInput(long? ExpectedCalendarVersion, int ExpectedProposalRevision);
public sealed record PatternInput(long? ExpectedCalendarVersion, DateOnly EffectiveFrom, WorkLocation[] Locations);
public sealed record CommentInput(long? ExpectedCalendarVersion, string Text, Guid? ProposalId = null);
public sealed record MutationReceipt(Guid ContextId, long Version, long CalendarVersion, Guid EventId);
public sealed record RequestedDayView(Guid Id, DateOnly LocalDate, WorkLocation Location, Availability Availability,
    bool Cancel, Guid? BaseDayId, long? BasePlanVersion, DayDecision Decision, long Version,
    string? Reason, Guid? DecidedBy, DateTimeOffset? DecidedAt);
public sealed record RequestView(Guid Id, Guid EmployeeId, Guid RootId, Guid? ParentRevisionId, int Revision,
    long Version, RequestState State, string Note, DateTimeOffset CreatedAt, DateTimeOffset? SubmittedAt,
    Guid? AcceptedProposalId, RequestedDayView[] Days);
public sealed record RequestPage(RequestView[] Items, int? NextOffset, long CalendarVersion);
public sealed record EffectiveDay(DateOnly LocalDate, WorkLocation Location, Availability? Availability,
    string Origin, long Version, Guid? SourceDayId, Guid? DecidedBy, Guid? SourceRequestId);
public sealed record PendingDay(Guid RequestId, long RequestVersion, RequestedDayView Day);
public sealed record ProposalView(Guid Id, Guid GroupId, int Revision, Guid RequestId, Guid AuthorId,
    string Reason, Guid[] AffectedDayIds, DayInput[] Days, ProposalState State, DateTimeOffset CreatedAt,
    Guid? AcceptedRequestId, DateTimeOffset? AcknowledgedAt, Guid? RequirementId = null, int? RequirementRevision = null);
public sealed record CalendarView(Guid EmployeeId, long CalendarVersion, string PlanningTimeZone,
    DateOnly From, DateOnly To, EffectiveDay[] EffectiveDays, PendingDay[] PendingDays, OnsiteView[] Requirements);
public sealed record CommentView(Guid Id, Guid RequestId, Guid? ProposalId, Guid AuthorId, string Text, DateTimeOffset CreatedAt);
public sealed record CommentPage(CommentView[] Items, int? NextOffset);
public sealed record ProposalPage(ProposalView[] Items, int? NextOffset);
public sealed record PatternView(DateOnly EffectiveFrom, WorkLocation[] Locations, long Version);
public sealed record PatternPage(long CalendarVersion, PatternView[] Items, int? NextOffset);
public sealed record PreviewDay(DateOnly LocalDate, bool IsWeekend);
public sealed record DatePreview(PreviewDay[] Days);

public partial interface IPlanningService
{
    Task<CalendarView> Calendar(Guid actor, Guid employee, DateOnly from, DateOnly to, CancellationToken ct);
    Task<RequestPage> Requests(Guid actor, Guid employee, int offset, int limit, CancellationToken ct, RequestState? state = null);
    Task<RequestView> Request(Guid actor, Guid employee, Guid id, CancellationToken ct);
    Task<ProposalPage> Proposals(Guid actor, Guid employee, Guid request, int offset, int limit, CancellationToken ct);
    Task<CommentPage> Comments(Guid actor, Guid employee, Guid request, int offset, int limit, CancellationToken ct);
    Task<PatternPage> Patterns(Guid actor, Guid employee, int offset, int limit, CancellationToken ct);
    Task<MutationReceipt> Draft(Guid actor, Guid employee, Guid? id, DraftInput input, string key, CancellationToken ct);
    Task<MutationReceipt> Submit(Guid actor, Guid employee, Guid id, SubmitInput input, string key, CancellationToken ct);
    Task<MutationReceipt> Decide(Guid actor, Guid employee, Guid id, DecisionInput input, string key, CancellationToken ct);
    Task<MutationReceipt> Withdraw(Guid actor, Guid employee, Guid id, WithdrawInput input, string key, CancellationToken ct);
    Task<MutationReceipt> Propose(Guid actor, Guid employee, Guid request, Guid? replaces, ProposalInput input, string key, CancellationToken ct);
    Task<MutationReceipt> Accept(Guid actor, Guid employee, Guid proposal, AcceptProposalInput input, string key, CancellationToken ct);
    Task<MutationReceipt> Pattern(Guid actor, Guid employee, PatternInput input, string key, CancellationToken ct);
    Task<MutationReceipt> Comment(Guid actor, Guid employee, Guid request, CommentInput input, string key, CancellationToken ct);
}
