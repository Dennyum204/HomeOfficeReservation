import 'dart:convert';
import 'dart:math';

import 'package:homeoffice_api/api.dart';

import '../auth/auth_controller.dart';

enum PlanningOperation {
  createDraft,
  editDraft,
  submit,
  decide,
  withdraw,
  propose,
  reviseProposal,
  accept,
  comment,
}

// A recovery envelope, not a parallel API DTO. The generated DTO owns the body.
class PlanningCommand {
  PlanningCommand({
    required this.actor,
    required this.employee,
    required this.operation,
    required this.body,
    required this.key,
    this.request,
    this.proposal,
  });
  factory PlanningCommand.prepare(
    String actor,
    String employee,
    PlanningOperation operation,
    Object dto, {
    String? request,
    String? proposal,
  }) {
    final random = Random.secure();
    final key = List.generate(
      24,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return PlanningCommand(
      actor: actor,
      employee: employee,
      operation: operation,
      body: jsonEncode(dto),
      key: key,
      request: request,
      proposal: proposal,
    );
  }
  final String actor, employee, body, key;
  final String? request, proposal;
  final PlanningOperation operation;
  Map<String, dynamic> toJson() => {
    'actor': actor,
    'employee': employee,
    'operation': operation.name,
    'body': body,
    'key': key,
    'request': request,
    'proposal': proposal,
  };
  factory PlanningCommand.fromJson(Map<String, dynamic> value) =>
      PlanningCommand(
        actor: value['actor'] as String,
        employee: value['employee'] as String,
        operation: PlanningOperation.values.byName(
          value['operation'] as String,
        ),
        body: value['body'] as String,
        key: value['key'] as String,
        request: value['request'] as String?,
        proposal: value['proposal'] as String?,
      );
}

class PlanningRepository {
  PlanningRepository(this.auth) : api = PlanningApi(auth.client);
  final AuthController auth;
  final PlanningApi api;
  Future<T> read<T>(Future<T> Function() query) =>
      auth.readAuthenticated(query);

  Future<List<MemberProfile>> employees() => read(() async {
    final actor = auth.member!;
    final result = <MemberProfile>[if (actor.isEmployee) actor];
    if (!actor.isManager) return result;
    final listed = (await auth.access.listMembers())!.members;
    for (final member in listed.where(
      (m) => m.active && m.isEmployee && m.memberId != actor.memberId,
    )) {
      try {
        final verified = await auth.access.checkManagementAccess(
          member.memberId,
        );
        if (verified != null) result.add(verified);
      } on ApiException catch (error) {
        if (error.code != 403 && error.code != 404) rethrow;
      }
    }
    return result;
  });

  Future<MutationReceipt> execute(PlanningCommand command) async {
    // Renew only through an idempotent read; never retry a write with a new key.
    final member = await read(() => auth.access.getCurrentMember());
    if (member?.memberId != command.actor) throw ApiException(401, '');
    final body = jsonDecode(command.body);
    final employee = command.employee, key = command.key;
    final result = await (switch (command.operation) {
      PlanningOperation.createDraft => api.createPlanningDraft(
        employee,
        key,
        DraftInput.fromJson(body)!,
      ),
      PlanningOperation.editDraft => api.editPlanningDraft(
        employee,
        command.request!,
        key,
        DraftInput.fromJson(body)!,
      ),
      PlanningOperation.submit => api.submitPlanningRequest(
        employee,
        command.request!,
        key,
        SubmitInput.fromJson(body)!,
      ),
      PlanningOperation.decide => api.decidePlanningDays(
        employee,
        command.request!,
        key,
        DecisionInput.fromJson(body)!,
      ),
      PlanningOperation.withdraw => api.withdrawPlanningDays(
        employee,
        command.request!,
        key,
        WithdrawInput.fromJson(body)!,
      ),
      PlanningOperation.propose => api.createCounterproposal(
        employee,
        command.request!,
        key,
        ProposalInput.fromJson(body)!,
      ),
      PlanningOperation.reviseProposal => api.reviseCounterproposal(
        employee,
        command.request!,
        command.proposal!,
        key,
        ProposalInput.fromJson(body)!,
      ),
      PlanningOperation.accept => api.acceptCounterproposal(
        employee,
        command.proposal!,
        key,
        AcceptProposalInput.fromJson(body)!,
      ),
      PlanningOperation.comment => api.addPlanningComment(
        employee,
        command.request!,
        key,
        CommentInput.fromJson(body)!,
      ),
    }).timeout(const Duration(seconds: 12));
    if (result == null) throw const FormatException('empty_mutation_receipt');
    return result;
  }
}
