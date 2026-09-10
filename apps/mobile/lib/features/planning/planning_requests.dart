import 'package:flutter/material.dart';
import 'package:homeoffice_api/api.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import 'planning_controller.dart';
import 'planning_dates.dart';
import 'planning_editor.dart';
import 'planning_repository.dart';
import 'planning_widgets.dart';

class PlanningRequests extends StatelessWidget {
  const PlanningRequests(this.controller, {super.key});
  final PlanningController controller;
  @override
  Widget build(BuildContext context) {
    final c = controller, s = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.planRequestsTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (c.own)
          FilledButton.icon(
            key: const Key('planning-new-request'),
            onPressed: c.canWrite ? c.newEditor : null,
            icon: const Icon(Icons.add),
            label: Text(c.hasSavedEditor ? s.planRestoreDraft : s.planNew),
          ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey('filter-${c.filter}'),
          initialValue: c.filter?.name ?? 'all',
          isExpanded: true,
          decoration: InputDecoration(labelText: s.planFilter),
          items: [
            DropdownMenuItem(value: 'all', child: Text(s.planAll)),
            for (final value in RequestState.values)
              DropdownMenuItem(
                value: value.name,
                child: Text(requestLabel(s, value)),
              ),
          ],
          onChanged: c.loading
              ? null
              : (value) => c.selectFilter(
                  value == 'all' ? null : RequestState.values.byName(value!),
                ),
        ),
        TextButton.icon(
          onPressed: c.loading ? null : c.refresh,
          icon: const Icon(Icons.refresh),
          label: Text(s.refresh),
        ),
        if (!c.loading && c.requests?.items.isEmpty == true)
          Text(s.planNoRequests),
        for (final request in c.requests?.items ?? <RequestView>[])
          PlanCard(
            key: Key('request-${request.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${requestLabel(s, request.state)} · ${s.planRevision} ${request.revision}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (request.days.isNotEmpty)
                  Text(
                    '${dayLabel(request.days.first.localDate)}${request.days.length > 1 ? ' → ${dayLabel(request.days.last.localDate)}' : ''}',
                  ),
                Text(requestCounts(s, request)),
                if (request.note.isNotEmpty)
                  Text(
                    request.note,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                OutlinedButton(
                  key: Key('open-request-${request.id}'),
                  onPressed: c.opening ? null : () => c.openRequest(request.id),
                  child: Text(s.planOpenRequest),
                ),
              ],
            ),
          ),
        Wrap(
          spacing: 12,
          children: [
            TextButton(
              onPressed: c.loading || c.offset == 0
                  ? null
                  : () => c.page((c.offset - 20).clamp(0, 10000)),
              child: Text(s.notificationPrevious),
            ),
            TextButton(
              onPressed: c.loading || c.requests?.nextOffset == null
                  ? null
                  : () => c.page(c.requests!.nextOffset!),
              child: Text(s.notificationNext),
            ),
          ],
        ),
      ],
    );
  }
}

class PlanningRequestDetail extends StatefulWidget {
  const PlanningRequestDetail(this.controller, {super.key});
  final PlanningController controller;
  @override
  State<PlanningRequestDetail> createState() => _PlanningRequestDetailState();
}

class _PlanningRequestDetailState extends State<PlanningRequestDetail> {
  PlanningController get c => widget.controller;
  String? error;
  void action(String action, {ProposalView? proposal}) {
    final s = AppLocalizations.of(context)!, request = c.detail!;
    final reason = c.reasons[request.id] ?? '';
    if (action == 'reject' && reason.trim().isEmpty) {
      setState(() => error = s.planReasonRequired);
      return;
    }
    if (!{'submit', 'accept', 'comment'}.contains(action) && c.chosen.isEmpty) {
      setState(() => error = s.planNoSelection);
      return;
    }
    final calendar = c.calendar!.calendarVersion;
    late final Object dto;
    late final PlanningOperation operation;
    late final String title;
    switch (action) {
      case 'submit':
        operation = PlanningOperation.submit;
        title = s.planSubmit;
        dto = SubmitInput(
          expectedCalendarVersion: calendar,
          expectedRequestVersion: request.version,
        );
      case 'withdraw':
        operation = PlanningOperation.withdraw;
        title = s.planWithdraw;
        dto = WithdrawInput(
          expectedCalendarVersion: calendar,
          expectedRequestVersion: request.version,
          days: c.chosenVersions,
        );
      case 'accept':
        operation = PlanningOperation.accept;
        title = s.planAccept;
        dto = AcceptProposalInput(
          expectedCalendarVersion: calendar,
          expectedProposalRevision: proposal!.revision,
        );
      case 'comment':
        operation = PlanningOperation.comment;
        title = s.planAddComment;
        dto = CommentInput(
          expectedCalendarVersion: calendar,
          text: c.commentDrafts[request.id] ?? '',
        );
      default:
        operation = PlanningOperation.decide;
        title = action == 'approve' ? s.planApprove : s.planReject;
        dto = DecisionInput(
          expectedCalendarVersion: calendar,
          expectedRequestVersion: request.version,
          days: c.chosenVersions,
          approve: action == 'approve',
          reason: reason,
        );
    }
    c.reviewCommand(
      c.prepare(operation, dto, request: request.id, proposal: proposal?.id),
      title,
      [
        if (action == 'accept') ...[
          s.planProposalHint,
          proposal!.reason,
          for (final day in proposal.days)
            '${dayLabel(day.localDate)} · ${day.cancel ? s.planCancelled : locationLabel(s, day.location, day.availability)}',
        ] else if (action == 'comment')
          c.commentDrafts[request.id] ?? ''
        else ...[
          for (final day in action == 'submit' ? request.days : c.chosen)
            '${dayLabel(day.localDate)} · ${day.cancel ? s.planCancelled : locationLabel(s, day.location, day.availability)}',
          if (reason.isNotEmpty) reason,
        ],
        if (action == 'withdraw') s.planWithdrawHint,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!, request = c.detail!;
    final submitted = request.state == RequestState.submitted;
    final onlyPending =
        c.chosen.isNotEmpty &&
        c.chosen.every((d) => d.decision == DayDecision.pending);
    final changeable =
        c.chosen.isNotEmpty &&
        c.chosen.every(
          (d) =>
              d.decision == DayDecision.pending ||
              d.decision == DayDecision.approved,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton.icon(
          onPressed: c.busy ? null : c.closeDetail,
          icon: const Icon(Icons.arrow_back),
          label: Text(s.planBack),
        ),
        Text(s.planDetails, style: Theme.of(context).textTheme.headlineSmall),
        Text(
          '${requestLabel(s, request.state)} · ${s.planRevision} ${request.revision}',
        ),
        Text(requestCounts(s, request), key: const Key('request-counts')),
        if (request.note.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(request.note, key: const Key('request-note')),
          ),
        if (request.parentRevisionId != null) ...[
          Text(s.planRevisionHint),
          TextButton(
            onPressed: c.opening
                ? null
                : () => c.openRequest(request.parentRevisionId!),
            child: Text(s.planPreviousRevision),
          ),
        ],
        TextButton.icon(
          onPressed: c.opening
              ? null
              : () => c.openRequest(request.id, preserveSelection: true),
          icon: const Icon(Icons.refresh),
          label: Text(s.refresh),
        ),
        Text(s.planHistory, style: Theme.of(context).textTheme.titleLarge),
        Text(s.planSelectionHint),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: c.locked
                  ? null
                  : () {
                      c.selectedDays = request.days
                          .where((d) => d.decision == DayDecision.pending)
                          .map((d) => d.id)
                          .toSet();
                      c.inputChanged();
                    },
              child: Text(s.planSelectPending),
            ),
            TextButton(
              onPressed: c.locked
                  ? null
                  : () {
                      c.selectedDays = {};
                      c.inputChanged();
                    },
              child: Text(s.planClearSelection),
            ),
          ],
        ),
        for (final day in request.days)
          PlanCard(
            key: Key('requested-${dateKey(day.localDate)}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckboxListTile(
                  key: Key('select-${dateKey(day.localDate)}'),
                  contentPadding: EdgeInsets.zero,
                  value: c.selectedDays.contains(day.id),
                  title: Text(dayLabel(day.localDate)),
                  subtitle: Text(decisionLabel(s, day.decision)),
                  onChanged: c.locked || request.state == RequestState.draft
                      ? null
                      : (value) => c.selectRequestedDay(day.id, value!),
                ),
                PlanLabel(
                  day.cancel
                      ? s.planCancelled
                      : locationLabel(s, day.location, day.availability),
                  day.cancel
                      ? Icons.event_busy
                      : locationIcon(day.location, day.availability),
                ),
                if (day.baseDayId != null) Text(s.planRevisionHint),
                if (day.reason?.isNotEmpty == true) Text(day.reason!),
                if (day.decidedAt != null)
                  Text(
                    DateFormat.yMd('pt_PT')
                        .add_Hm()
                        .format(day.decidedAt!.toLocal()),
                  ),
              ],
            ),
          ),
        if (c.own && request.state == RequestState.draft)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                key: const Key('request-edit'),
                onPressed: c.canWrite
                    ? () => c.editRequest(EditorMode.edit)
                    : null,
                child: Text(s.planEditDraft),
              ),
              FilledButton(
                key: const Key('request-submit'),
                onPressed: c.canWrite ? () => action('submit') : null,
                child: Text(s.planSubmit),
              ),
            ],
          ),
        if (c.own && submitted) ...[
          Text(s.planWithdrawHint),
          OutlinedButton(
            key: const Key('request-withdraw'),
            onPressed: c.canWrite && onlyPending
                ? () => action('withdraw')
                : null,
            child: Text(s.planWithdraw),
          ),
        ],
        if (c.own && request.state != RequestState.draft) ...[
          Text(s.planRevisionHint),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                key: const Key('request-revise'),
                onPressed: c.canWrite && changeable
                    ? () => c.editRequest(EditorMode.revision)
                    : null,
                child: Text(s.planChange),
              ),
              OutlinedButton(
                key: const Key('request-cancel'),
                onPressed:
                    c.canWrite &&
                        c.chosen.isNotEmpty &&
                        c.chosen.every(
                          (d) => d.decision == DayDecision.approved,
                        )
                    ? () => c.editRequest(EditorMode.revision, cancel: true)
                    : null,
                child: Text(s.planCancelDays),
              ),
            ],
          ),
        ],
        if (c.manager) ...[
          TextFormField(
            key: ValueKey('decision-reason-${request.id}'),
            maxLength: 1000,
            initialValue: c.reasons[request.id],
            minLines: 2,
            maxLines: 5,
            enabled: !c.locked,
            decoration: InputDecoration(labelText: s.planReason),
            onChanged: (value) {
              c.reasons[request.id] = value;
              c.inputChanged();
            },
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                key: const Key('request-approve'),
                onPressed: c.canWrite && submitted && onlyPending
                    ? () => action('approve')
                    : null,
                child: Text(s.planApprove),
              ),
              OutlinedButton(
                key: const Key('request-reject'),
                onPressed: c.canWrite && submitted && onlyPending
                    ? () => action('reject')
                    : null,
                child: Text(s.planReject),
              ),
              OutlinedButton(
                key: const Key('request-propose'),
                onPressed: c.canWrite && changeable
                    ? () => c.editRequest(EditorMode.proposal)
                    : null,
                child: Text(s.planPropose),
              ),
            ],
          ),
        ],
        if (error != null) Semantics(liveRegion: true, child: Text(error!)),
        const SizedBox(height: 24),
        Text(s.planProposals, style: Theme.of(context).textTheme.titleLarge),
        Text(s.planProposalHint),
        for (final proposal in c.proposals?.items ?? <ProposalView>[])
          PlanCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${s.planRevision} ${proposal.revision} · ${proposal.state == ProposalState.open
                      ? s.planOpenProposal
                      : proposal.state == ProposalState.accepted
                      ? s.planAcceptedProposal
                      : s.planSuperseded}',
                ),
                Text(proposal.reason),
                for (final day in proposal.days)
                  Text(
                    '${dayLabel(day.localDate)} · ${day.cancel ? s.planCancelled : locationLabel(s, day.location, day.availability)}',
                  ),
                if (c.own && proposal.state == ProposalState.open)
                  FilledButton(
                    key: Key('accept-${proposal.id}'),
                    onPressed: c.canWrite
                        ? () => action('accept', proposal: proposal)
                        : null,
                    child: Text(s.planAccept),
                  ),
                if (c.manager && proposal.state != ProposalState.superseded)
                  OutlinedButton(
                    onPressed: c.canWrite
                        ? () {
                            c.selectedDays = proposal.affectedDayIds.toSet();
                            c.editRequest(
                              EditorMode.proposal,
                              proposal: proposal,
                            );
                          }
                        : null,
                    child: Text(s.planReviseProposal),
                  ),
                if (proposal.acceptedRequestId != null)
                  TextButton(
                    onPressed: c.opening
                        ? null
                        : () => c.openRequest(proposal.acceptedRequestId!),
                    child: Text(s.planAcceptedRequest),
                  ),
              ],
            ),
          ),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: c.opening || c.proposalOffset == 0
                  ? null
                  : () {
                      c.proposalOffset = (c.proposalOffset - 20).clamp(
                        0,
                        10000,
                      );
                      c.openRequest(request.id, preserveSelection: true);
                    },
              child: Text(s.notificationPrevious),
            ),
            TextButton(
              onPressed: c.opening || c.proposals?.nextOffset == null
                  ? null
                  : () {
                      c.proposalOffset = c.proposals!.nextOffset!;
                      c.openRequest(request.id, preserveSelection: true);
                    },
              child: Text(s.notificationNext),
            ),
          ],
        ),
        Text(s.planComments, style: Theme.of(context).textTheme.titleLarge),
        for (final comment in c.comments?.items ?? <CommentView>[])
          PlanCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.authorId == c.actor
                      ? c.repository.auth.member!.displayName
                      : c.employees
                                .where((m) => m.memberId == comment.authorId)
                                .firstOrNull
                                ?.displayName ??
                            s.authManager,
                ),
                Text(comment.text),
                Text(
                  DateFormat.yMd('pt_PT')
                      .add_Hm()
                      .format(comment.createdAt.toLocal()),
                ),
              ],
            ),
          ),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: c.opening || c.commentOffset == 0
                  ? null
                  : () {
                      c.commentOffset = (c.commentOffset - 20).clamp(0, 10000);
                      c.openRequest(request.id, preserveSelection: true);
                    },
              child: Text(s.notificationPrevious),
            ),
            TextButton(
              onPressed: c.opening || c.comments?.nextOffset == null
                  ? null
                  : () {
                      c.commentOffset = c.comments!.nextOffset!;
                      c.openRequest(request.id, preserveSelection: true);
                    },
              child: Text(s.notificationNext),
            ),
          ],
        ),
        TextFormField(
          key: ValueKey('comment-${request.id}-${c.commentEditGeneration}'),
          maxLength: 2000,
          initialValue: c.commentDrafts[request.id],
          minLines: 2,
          maxLines: 6,
          enabled: !c.locked,
          decoration: InputDecoration(labelText: s.planComment),
          onChanged: (value) {
            c.commentDrafts[request.id] = value;
            c.inputChanged();
          },
        ),
        OutlinedButton(
          onPressed:
              c.canWrite &&
                  (c.commentDrafts[request.id]?.trim().isNotEmpty ?? false)
              ? () => action('comment')
              : null,
          child: Text(s.planAddComment),
        ),
      ],
    );
  }
}
