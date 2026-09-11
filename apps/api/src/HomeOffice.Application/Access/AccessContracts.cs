using HomeOffice.Domain.Access;

namespace HomeOffice.Application.Access;

public sealed record MemberProfile(Guid MemberId, Guid OrganizationId, string OrganizationName,
    string DisplayName, string Email, bool Active, bool IsEmployee, bool IsManager, bool IsAccountAdministrator);
public sealed record MemberList(MemberProfile[] Members);
public sealed record ProvisionMemberRequest(string Email, string DisplayName, bool IsEmployee, bool IsManager, bool IsAccountAdministrator);
public sealed record UpdateMemberRequest(bool Active, bool IsEmployee, bool IsManager, bool IsAccountAdministrator,
    long? ExpectedAccessVersion = null, Guid? CommandId = null);
public sealed record SetManagerRequest(Guid? ManagerId, long? ExpectedAccessVersion = null, Guid? CommandId = null);
public sealed record OperationResult(bool Succeeded, string Code);
public sealed record InvitationChangeRequest(Guid CommandId, long ExpectedVersion);
public sealed record InvitationProfile(Guid MemberId, string Email, string DisplayName, bool Active,
    bool IsEmployee, bool IsManager, bool IsAccountAdministrator, Guid? ManagerId, bool ManagerRelationshipValid,
    bool EmailConfirmed, string State, long Version, string DeliveryState, int DeliveryAttempts,
    string? DeliveryError, DateTimeOffset? CodeExpiresAt, DateTimeOffset? DeliveredAt,
    DateTimeOffset? AcceptedAt, DateTimeOffset? CancelledAt, DateTimeOffset? ResendAvailableAt, long AccessVersion);
public sealed record InvitationPage(InvitationProfile[] Members, Guid? NextAfter);

public interface IMemberDirectory
{
    Task<Member?> CurrentAsync(string identityUserId);
    Task<MemberProfile?> ProfileAsync(Member actor, Guid memberId, bool managementOnly = false);
    Task<MemberList> ListAsync(Member actor);
    Task<OperationResult> UpdateAsync(Member actor, Guid memberId, UpdateMemberRequest request);
    Task<OperationResult> AssignManagerAsync(Member actor, Guid employeeId, Guid? managerId,
        long? expectedAccessVersion = null, Guid? commandId = null);
}

public interface IAccountEmail
{
    Task SendAsync(string email, string purpose, string code);
}

public sealed class EmailDeliveryException : Exception;
