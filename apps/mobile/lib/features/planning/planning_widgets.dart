import 'package:flutter/material.dart';
import 'package:homeoffice_api/api.dart';

import '../../l10n/generated/app_localizations.dart';
import 'planning_controller.dart';

String locationLabel(
  AppLocalizations s,
  WorkLocation location,
  Availability? availability,
) => availability == Availability.leave
    ? s.planLeave
    : availability == Availability.unavailable
    ? s.planUnavailable
    : switch (location) {
        WorkLocation.remotePortugal => s.planRemote,
        WorkLocation.officeSwitzerland => s.planOnsite,
        _ => s.planUnplanned,
      };
IconData locationIcon(WorkLocation location, Availability? availability) =>
    availability == Availability.leave
    ? Icons.beach_access_outlined
    : availability == Availability.unavailable
    ? Icons.do_not_disturb_alt_outlined
    : location == WorkLocation.remotePortugal
    ? Icons.home_outlined
    : location == WorkLocation.officeSwitzerland
    ? Icons.business_outlined
    : Icons.horizontal_rule;
Color locationColor(WorkLocation location, Availability? availability) =>
    availability != Availability.working
    ? const Color(0xff52616b)
    : location == WorkLocation.remotePortugal
    ? const Color(0xff246142)
    : const Color(0xff20548a);
String decisionLabel(AppLocalizations s, DayDecision value) => switch (value) {
  DayDecision.pending => s.planPending,
  DayDecision.approved => s.planApproved,
  DayDecision.rejected => s.planRejected,
  DayDecision.withdrawn => s.planWithdrawn,
  DayDecision.cancelled => s.planCancelled,
  _ => s.planSuperseded,
};
String requestLabel(AppLocalizations s, RequestState value) => switch (value) {
  RequestState.draft => s.planDraft,
  RequestState.submitted => s.planSubmitted,
  RequestState.closed => s.planClosed,
  RequestState.withdrawn => s.planWithdrawn,
};
String requestCounts(AppLocalizations s, RequestView item) => s.planDayCounts(
  item.days.where((d) => d.decision == DayDecision.approved).length,
  item.days.where((d) => d.decision == DayDecision.pending).length,
);
String failureLabel(AppLocalizations s, PlanningFailure failure) =>
    switch (failure) {
      PlanningFailure.none => '',
      PlanningFailure.network => s.planNetwork,
      PlanningFailure.forbidden => s.planForbidden,
      PlanningFailure.missing => s.planMissing,
      PlanningFailure.stale => s.planStale,
      PlanningFailure.conflict => s.planConflictError,
      PlanningFailure.invalid => s.planInvalid,
      PlanningFailure.limited => s.planLimited,
      PlanningFailure.storage => s.planStorage,
      PlanningFailure.uncertain => s.planUncertain,
    };

class PlanningNotice extends StatelessWidget {
  const PlanningNotice(this.controller, {super.key});
  final PlanningController controller;
  @override
  Widget build(BuildContext context) {
    final c = controller, s = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (c.loading || c.opening || c.busy) const LinearProgressIndicator(),
        if (c.busy) Text(s.planSending),
        for (final failure in {
          c.failure,
          c.readFailure,
        }.where((f) => f != PlanningFailure.none))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Semantics(
              liveRegion: true,
              child: Text(
                failure == c.failure && c.problemCode != null
                    ? switch (c.problemCode) {
                        'stale_plan_base' ||
                        'invalid_revision_base' => s.planBaseMissing,
                        'pending_overlap' => s.planOverlap,
                        'approved_day_requires_revision' =>
                          s.planRequiresRevision,
                        _ => failureLabel(s, failure),
                      }
                    : failureLabel(s, failure),
                key: Key('planning-error-${failure.name}'),
              ),
            ),
          ),
        if (c.journal != null)
          FilledButton.tonal(
            onPressed: c.busy ? null : c.recover,
            key: const Key('planning-recover'),
            child: Text(s.planRecover),
          ),
        if (c.needsReview)
          OutlinedButton(
            onPressed: c.loading || c.opening || c.dataStale
                ? null
                : c.reviewed,
            key: const Key('planning-reviewed'),
            child: Text(s.planReviewed),
          ),
        if (c.readFailure != PlanningFailure.none || c.failedRequest != null)
          TextButton.icon(
            onPressed: c.loading
                ? null
                : () => c.failedRequest != null
                      ? c.openRequest(c.failedRequest!)
                      : c.initialized
                      ? c.refresh()
                      : c.initialize(),
            icon: const Icon(Icons.refresh),
            label: Text(s.retry),
          ),
      ],
    );
  }
}

class PlanLabel extends StatelessWidget {
  const PlanLabel(
    this.text,
    this.icon, {
    super.key,
    this.color = const Color(0xff264e3e),
  });
  final String text;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(text, style: TextStyle(color: color)),
        ),
      ],
    ),
  );
}

class PlanCard extends StatelessWidget {
  const PlanCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Card(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}
