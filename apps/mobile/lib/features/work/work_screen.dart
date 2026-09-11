import 'package:flutter/material.dart';
import 'package:homeoffice_api/api.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/components.dart';
import '../planning/planning_controller.dart';
import '../planning/planning_dates.dart';
import '../planning/planning_repository.dart';
import '../planning/planning_widgets.dart';
import 'work_editor_view.dart';
import 'work_widgets.dart';

class WorkScreen extends StatelessWidget {
  const WorkScreen(this.c, {super.key, required this.onRequests});
  final PlanningController c;
  final VoidCallback onRequests;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: c,
    builder: (context, _) {
      final s = AppLocalizations.of(context)!;
      final internal =
          c.review != null || c.workEditor != null || c.workId != null;
      void back() {
        if (c.review != null) {
          c.closeReview();
        } else if (c.workEditor != null) {
          c.closeWorkEditor();
        } else {
          c.closeWork();
          c.loadWork();
        }
      }

      return PopScope(
        canPop: !internal,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && !c.busy) back();
        },
        child: ListView(
          key: PageStorageKey(
            'work-${c.employeeId}-${c.workKind}-${c.workId}-${c.workEditor != null}-${c.review != null}',
          ),
          padding: const EdgeInsets.all(16),
          children: [
            SectionHeading(s.workTitle),
            PlanningEmployeePicker(c, work: true),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(s.workOnsite),
                  selected: c.workKind == WorkContext.requirement,
                  onSelected:
                      c.locked || c.review != null || c.workEditor != null
                      ? null
                      : (_) => c.selectWorkKind(WorkContext.requirement),
                ),
                ChoiceChip(
                  label: Text(s.tasks),
                  selected: c.workKind == WorkContext.task,
                  onSelected:
                      c.locked || c.review != null || c.workEditor != null
                      ? null
                      : (_) => c.selectWorkKind(WorkContext.task),
                ),
              ],
            ),
            Text(
              c.workKind == WorkContext.requirement
                  ? s.workOnsiteIntro
                  : s.workTaskIntro,
            ),
            PlanningNotice(c),
            if (c.workLoading) const LinearProgressIndicator(),
            TextButton.icon(
              key: const Key('work-refresh'),
              onPressed: c.workLoading
                  ? null
                  : () => c.workId == null
                        ? c.loadWork()
                        : c.openWork(
                            c.workKind,
                            c.workId!,
                            preserveEditor: true,
                          ),
              icon: const Icon(Icons.refresh),
              label: Text(
                c.failure == PlanningFailure.none ? s.refresh : s.retry,
              ),
            ),
            if (c.review != null)
              PlanningConfirmation(c)
            else if (c.workEditor != null)
              WorkEditorView(c, key: ObjectKey(c.workEditor))
            else if (c.workId != null) ...[
              if (c.requirement != null || c.task != null)
                WorkDetail(c, onRequests: onRequests)
              else if (!c.workLoading)
                Text(s.workCurrentMissing),
              TextButton(
                onPressed: c.busy ? null : back,
                child: Text(s.workClose),
              ),
            ] else
              WorkList(c),
          ],
        ),
      );
    },
  );
}

class WorkList extends StatelessWidget {
  const WorkList(this.c, {super.key});
  final PlanningController c;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!,
        onsite = c.workKind == WorkContext.requirement;
    final items = <Object>[
      if (onsite) ...?c.requirements?.items else ...?c.tasks?.items,
    ];
    final next = onsite ? c.requirements?.nextOffset : c.tasks?.nextOffset;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (c.manager)
          FilledButton.icon(
            key: const Key('work-new'),
            onPressed: c.workCanWrite ? () => c.editWork(creating: true) : null,
            icon: const Icon(Icons.add),
            label: Text(onsite ? s.workNewOnsite : s.workNewTask),
          ),
        DropdownButtonFormField<String>(
          key: ValueKey('work-filter-${c.workKind}'),
          initialValue: onsite
              ? c.requirementFilter?.name ?? ''
              : c.taskFilter?.name ?? '',
          isExpanded: true,
          decoration: InputDecoration(labelText: s.workFilter),
          items: [
            DropdownMenuItem(value: '', child: Text(s.planAll)),
            if (onsite)
              for (final v in OnsiteState.values)
                DropdownMenuItem(value: v.name, child: Text(onsiteLabel(s, v)))
            else
              for (final v in AssignedTaskState.values)
                DropdownMenuItem(value: v.name, child: Text(taskLabel(s, v))),
          ],
          onChanged: c.workLoading
              ? null
              : (v) {
                  if (onsite) {
                    c.requirementFilter = v == ''
                        ? null
                        : OnsiteState.values.byName(v!);
                  } else {
                    c.taskFilter = v == ''
                        ? null
                        : AssignedTaskState.values.byName(v!);
                  }
                  c.loadWork(page: 0);
                },
        ),
        if (!c.workLoading && items.isEmpty) Text(s.workNoItems),
        for (final item in items)
          PlanCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item is OnsiteView) ...[
                  Text(
                    item.reason,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('${dayLabel(item.from)} — ${dayLabel(item.to)}'),
                  PlanLabel(
                    onsiteLabel(s, item.state),
                    Icons.push_pin_outlined,
                  ),
                  Text(item.location),
                  if (item.state == OnsiteState.needsResolution)
                    Text(s.workConflict),
                  TextButton(
                    key: Key('work-open-${item.id}'),
                    onPressed: () =>
                        c.openWork(WorkContext.requirement, item.id),
                    child: Text(s.workOpen),
                  ),
                ] else if (item is TaskView) ...[
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('${s.workDeadline}: ${dayLabel(item.deadline)}'),
                  PlanLabel(taskLabel(s, item.state), Icons.task_alt),
                  if (item.requiresOnsite) Text(s.workRequiresOnsite),
                  TextButton(
                    key: Key('work-open-${item.id}'),
                    onPressed: () => c.openWork(WorkContext.task, item.id),
                    child: Text(s.workOpen),
                  ),
                ],
              ],
            ),
          ),
        Wrap(
          spacing: 12,
          children: [
            TextButton(
              onPressed: c.workOffset == 0 || c.workLoading
                  ? null
                  : () => c.loadWork(page: c.workOffset - 25),
              child: Text(s.notificationPrevious),
            ),
            TextButton(
              onPressed: next == null || c.workLoading
                  ? null
                  : () => c.loadWork(page: next),
              child: Text(s.notificationNext),
            ),
          ],
        ),
      ],
    );
  }
}

class WorkDetail extends StatelessWidget {
  const WorkDetail(this.c, {super.key, required this.onRequests});
  final PlanningController c;
  final VoidCallback onRequests;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!, r = c.requirement, t = c.task;
    void review(
      PlanningOperation op,
      Object input,
      String title,
      List<String> lines,
    ) {
      if (c.workCanWrite) {
        c.reviewCommand(
          c.prepare(op, input, request: c.workId, workContext: c.workKind),
          title,
          lines,
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (r != null) ...[
          Text(
            r.reason,
            key: const Key('work-detail-title'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text('${dayLabel(r.from)} — ${dayLabel(r.to)}'),
          Text(r.location),
          if (r.reference.isNotEmpty) Text(r.reference),
          PlanLabel(onsiteLabel(s, r.state), Icons.push_pin_outlined),
          Text('${s.workRevision} ${r.revision}'),
          Text(
            r.readAt != null ? s.workRead : s.workUnread,
            key: const Key('work-read-state'),
          ),
          Text(s.workReadHint),
          if (c.own && r.readAt == null && r.state != OnsiteState.cancelled)
            FilledButton(
              key: const Key('work-acknowledge'),
              onPressed: c.workCanWrite
                  ? () => review(
                      PlanningOperation.acknowledgeRequirement,
                      OnsiteAcknowledgeInput(
                        expectedCalendarVersion: c.calendar!.calendarVersion,
                        expectedVersion: r.version,
                        revision: r.revision,
                      ),
                      s.workAcknowledge,
                      [
                        r.reason,
                        '${s.workRevision} ${r.revision}',
                        s.workReadHint,
                      ],
                    )
                  : null,
              child: Text(s.workAcknowledge),
            ),
          if (c.workConflicts != null)
            WorkConflicts(
              preview: c.workConflicts!,
              manager: c.manager,
              onRequest: (id) {
                onRequests();
                c.openRequest(id);
              },
              onResolve: c.workCanWrite
                  ? (id) async {
                      await c.resolveRequirement(id);
                      if (c.editor != null && c.active) onRequests();
                    }
                  : null,
            ),
          if (c.manager) ...[
            if (r.state != OnsiteState.cancelled) ...[
              OutlinedButton(
                key: const Key('work-edit'),
                onPressed: c.workCanWrite ? () => c.editWork() : null,
                child: Text(s.workEdit),
              ),
              OutlinedButton(
                key: const Key('work-cancel'),
                onPressed: c.workCanWrite
                    ? () => review(
                        PlanningOperation.cancelRequirement,
                        WorkVersionInput(
                          expectedCalendarVersion: c.calendar!.calendarVersion,
                          expectedVersion: r.version,
                        ),
                        s.workCancel,
                        [
                          r.reason,
                          '${dayLabel(r.from)} — ${dayLabel(r.to)}',
                          s.workLinkHint,
                        ],
                      )
                    : null,
                child: Text(s.workCancel),
              ),
              FilledButton.tonal(
                key: const Key('work-assign-linked'),
                onPressed: c.workCanWrite
                    ? () => c.editWork(creating: true, linked: r)
                    : null,
                child: Text(s.workNewTask),
              ),
            ],
          ],
        ],
        if (t != null) ...[
          Text(
            t.title,
            key: const Key('work-detail-title'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(t.description),
          Text('${s.workDeadline}: ${dayLabel(t.deadline)}'),
          PlanLabel(taskLabel(s, t.state), Icons.task_alt),
          if (t.progressNote.isNotEmpty) Text(t.progressNote),
          if (t.requiresOnsite) ...[
            Text(s.workRequiresOnsite),
            Text(s.workRequiresHint),
          ],
          if (t.requirementId != null) ...[
            Text(s.workLinked),
            if (c.linkedRequirement != null)
              Text(
                '${c.linkedRequirement!.reason} · ${onsiteLabel(s, c.linkedRequirement!.state)}',
              ),
            Text(s.workLinkHint),
            TextButton(
              onPressed: () =>
                  c.openWork(WorkContext.requirement, t.requirementId!),
              child: Text(s.workOpenLinked),
            ),
          ],
          if (c.manager)
            OutlinedButton(
              key: const Key('work-edit'),
              onPressed: c.workCanWrite ? () => c.editWork() : null,
              child: Text(s.workEdit),
            ),
          if (c.own) ...[
            if ({
              AssignedTaskState.todo,
              AssignedTaskState.inProgress,
            }.contains(t.state))
              FilledButton(
                key: const Key('work-progress'),
                onPressed: c.workCanWrite
                    ? () => c.editWork(progress: true)
                    : null,
                child: Text(s.workProgress),
              )
            else
              Text(s.workTerminal),
          ],
        ],
        const SizedBox(height: 16),
        Text(s.workHistory, style: Theme.of(context).textTheme.titleLarge),
        TextFormField(
          key: ValueKey(
            'work-comment-${c.workCommentKey}-${c.commentEditGeneration}',
          ),
          initialValue: c.workCommentDrafts[c.workCommentKey] ?? '',
          maxLength: 2000,
          maxLines: 3,
          enabled: !c.locked,
          decoration: InputDecoration(labelText: s.workComment),
          onChanged: (value) {
            c.workCommentDrafts[c.workCommentKey] = value;
            c.inputChanged();
          },
        ),
        TextButton(
          key: const Key('work-comment-send'),
          onPressed:
              c.workCanWrite &&
                  (c.workCommentDrafts[c.workCommentKey]?.trim().isNotEmpty ??
                      false)
              ? () => review(
                  PlanningOperation.workComment,
                  WorkCommentInput(
                    expectedCalendarVersion: c.calendar!.calendarVersion,
                    text: c.workCommentDrafts[c.workCommentKey]!,
                  ),
                  s.planAddComment,
                  [c.workCommentDrafts[c.workCommentKey]!],
                )
              : null,
          child: Text(s.planAddComment),
        ),
        for (final entry in c.workEntries?.items ?? <WorkEntryView>[])
          WorkHistoryEntry(entry),
        Wrap(
          spacing: 12,
          children: [
            TextButton(
              onPressed: c.entryOffset == 0 || c.workLoading
                  ? null
                  : () {
                      c.entryOffset -= 25;
                      c.openWork(c.workKind, c.workId!);
                    },
              child: Text(s.notificationPrevious),
            ),
            TextButton(
              onPressed: c.workEntries?.nextOffset == null || c.workLoading
                  ? null
                  : () {
                      c.entryOffset = c.workEntries!.nextOffset!;
                      c.openWork(c.workKind, c.workId!);
                    },
              child: Text(s.notificationNext),
            ),
          ],
        ),
      ],
    );
  }
}
