import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:homeoffice_api/api.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../planning/planning_dates.dart';
import '../planning/planning_widgets.dart';
import '../../theme/components.dart';

String onsiteLabel(AppLocalizations s, OnsiteState value) => switch (value) {
  OnsiteState.active => s.workActive,
  OnsiteState.needsResolution => s.workNeedsResolution,
  OnsiteState.cancelled => s.workCancelled,
};
String taskLabel(AppLocalizations s, AssignedTaskState value) =>
    switch (value) {
      AssignedTaskState.todo => s.workTodo,
      AssignedTaskState.inProgress => s.workInProgress,
      AssignedTaskState.done => s.workDone,
      AssignedTaskState.cancelled => s.workCancelled,
    };
String conflictLabel(AppLocalizations s, String code) => switch (code) {
  'approved_remote' => s.workRemoteConflict,
  'approved_unavailability' => s.workAvailabilityConflict,
  'pending_request' => s.workPendingConflict,
  'different_onsite_location' => s.workLocationConflict,
  _ => s.workOtherConflict,
};

class WorkConflicts extends StatelessWidget {
  const WorkConflicts({
    super.key,
    required this.preview,
    required this.manager,
    this.onRequest,
    this.onResolve,
  });
  final OnsitePreview preview;
  final bool manager;
  final ValueChanged<String>? onRequest, onResolve;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final requests = preview.conflicts
        .map((c) => c.requestId)
        .whereType<String>()
        .toSet();
    return PlanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlanLabel(
            onsiteLabel(s, preview.result),
            preview.result == OnsiteState.needsResolution
                ? Icons.warning_amber
                : Icons.push_pin_outlined,
            tone: preview.result == OnsiteState.needsResolution
                ? BadgeTone.danger
                : BadgeTone.neutral,
          ),
          Text(
            preview.result == OnsiteState.needsResolution
                ? s.workConflict
                : s.workNoConflicts,
          ),
          if (preview.result == OnsiteState.needsResolution)
            Text(manager ? s.workManagerNext : s.workEmployeeNext),
          for (final conflict in preview.conflicts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '${dayLabel(conflict.localDate)} · ${conflictLabel(s, conflict.code)}',
              ),
            ),
          for (final id in requests)
            Wrap(
              spacing: 8,
              children: [
                if (onRequest != null)
                  TextButton(
                    onPressed: () => onRequest!(id),
                    child: Text(s.workOpenRequest),
                  ),
                if (manager && onResolve != null)
                  FilledButton.tonal(
                    key: Key('work-resolve-$id'),
                    onPressed: () => onResolve!(id),
                    child: Text(s.workResolve),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class WorkHistoryEntry extends StatelessWidget {
  const WorkHistoryEntry(this.entry, {super.key});
  final WorkEntryView entry;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final title = switch (entry.action) {
      'onsite.created' => s.workCreated,
      'onsite.edited' => s.workEdited,
      'onsite.cancelled' => s.workCancelled,
      'onsite.read' => s.workRead,
      'onsite.revalidated' => s.workRevalidated,
      'task.assigned' => s.workAssigned,
      'task.updated' => s.workTaskEdited,
      'task.progress' => s.workProgressUpdated,
      'work.commented' => s.workComment,
      _ => s.workHistory,
    };
    Map<String, dynamic> value = {};
    try {
      value = Map<String, dynamic>.from(jsonDecode(entry.snapshotJson) as Map);
    } catch (_) {
      /* Optional historical snapshot, not trusted UI markup. */
    }
    final details = <String>[];
    for (final key in [
      'reason',
      'title',
      'description',
      'location',
      'reference',
      'progressNote',
    ]) {
      if (value[key] is String && (value[key] as String).isNotEmpty) {
        details.add(value[key] as String);
      }
    }
    for (final key in ['from', 'to', 'deadline']) {
      final date = value[key] is String
          ? DateTime.tryParse(value[key] as String)
          : null;
      if (date != null) {
        details.add(
          '${key == "from"
              ? s.workFrom
              : key == "to"
              ? s.workTo
              : s.workDeadline}: ${dayLabel(date)}',
        );
      }
    }
    final state = value['title'] is String
        ? AssignedTaskState.fromJson(value['state'])
        : null;
    final onsite = state == null ? OnsiteState.fromJson(value['state']) : null;
    if (state != null) details.add(taskLabel(s, state));
    if (onsite != null) details.add(onsiteLabel(s, onsite));
    if (value['revision'] is int) {
      details.add('${s.workRevision} ${value['revision']}');
    }
    return PlanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          Text(
            DateFormat.yMd('pt_PT').add_Hm().format(entry.createdAt.toLocal()),
          ),
          if (entry.text.isNotEmpty) Text(entry.text),
          for (final line in details) Text(line),
        ],
      ),
    );
  }
}
