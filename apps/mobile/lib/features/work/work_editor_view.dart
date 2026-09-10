import 'package:flutter/material.dart';
import 'package:homeoffice_api/api.dart';

import '../../l10n/generated/app_localizations.dart';
import '../planning/planning_controller.dart';
import '../planning/planning_dates.dart';
import '../planning/planning_repository.dart';
import 'work_widgets.dart';

class WorkEditorView extends StatefulWidget {
  const WorkEditorView(this.c, {super.key});
  final PlanningController c;
  @override
  State<WorkEditorView> createState() => _WorkEditorViewState();
}

class _WorkEditorViewState extends State<WorkEditorView> {
  final form = GlobalKey<FormState>();
  PlanningController get c => widget.c;
  String? error;
  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!,
        e = c.workEditor!,
        r = e.onsite,
        t = e.task,
        p = e.progress;
    final enabled = !c.locked;
    Widget text(
      String key,
      String label,
      String value,
      ValueChanged<String> changed, {
      int max = 2000,
      bool required = false,
      int lines = 1,
    }) => TextFormField(
      key: Key(key),
      initialValue: value,
      enabled: enabled,
      maxLength: max,
      maxLines: lines,
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
          required && (value?.trim().isEmpty ?? true) ? s.workRequired : null,
      onChanged: (value) {
        changed(value);
        c.workInputChanged();
      },
    );
    Future<void> date(bool first) async {
      final current = r != null ? (first ? r.from : r.to) : t!.deadline;
      final today = planningToday(
        c.calendar?.planningTimeZone ?? 'Europe/Zurich',
      );
      final picked = await showDatePicker(
        context: context,
        initialDate: current,
        firstDate: current.isBefore(today) ? current : today,
        lastDate: shiftDay(today, 730),
      );
      if (picked == null || !mounted || c.workEditor != e || !c.active) return;
      if (r != null) {
        e.onsite = first
            ? e.onsite!.copyWith(from: dayOnly(picked))
            : e.onsite!.copyWith(to: dayOnly(picked));
      } else {
        e.task = e.task!.copyWith(deadline: dayOnly(picked));
      }
      c.workInputChanged();
    }

    void save() {
      if (!form.currentState!.validate()) return;
      if (r != null &&
          (r.to.isBefore(r.from) ||
              c.editorPreview == null ||
              c.editorPreviewFingerprint != c.workPreviewFingerprint ||
              c.editorPreview!.calendarVersion !=
                  c.calendar?.calendarVersion)) {
        setState(
          () => error = r.to.isBefore(r.from)
              ? s.workRequired
              : s.workPreviewRequired,
        );
        return;
      }
      final version = c.calendar!.calendarVersion;
      final Object dto;
      final PlanningOperation operation;
      final List<String> lines;
      if (r != null) {
        dto = r.copyWith(
          expectedCalendarVersion: version,
          expectedVersion: e.id == null ? null : c.requirement!.version,
        );
        operation = e.id == null
            ? PlanningOperation.createRequirement
            : PlanningOperation.editRequirement;
        lines = [
          r.reason,
          '${dayLabel(r.from)} — ${dayLabel(r.to)}',
          r.location,
          r.reference,
          s.workReadHint,
          onsiteLabel(s, c.editorPreview!.result),
          for (final conflict in c.editorPreview!.conflicts)
            '${dayLabel(conflict.localDate)} · ${conflictLabel(s, conflict.code)}',
        ];
      } else if (t != null) {
        dto = t.copyWith(
          expectedCalendarVersion: version,
          expectedVersion: e.id == null ? null : c.task!.version,
        );
        operation = e.id == null
            ? PlanningOperation.createTask
            : PlanningOperation.editTask;
        lines = [
          t.title,
          t.description,
          '${s.workDeadline}: ${dayLabel(t.deadline)}',
          taskLabel(s, t.state),
          if (t.requiresOnsite) s.workRequiresHint,
          s.workLinkHint,
        ];
      } else {
        dto = p!.copyWith(
          expectedCalendarVersion: version,
          expectedVersion: c.task!.version,
        );
        operation = PlanningOperation.progressTask;
        lines = [c.task!.title, taskLabel(s, p.state), p.note];
      }
      if (c.workCanWrite) {
        c.reviewCommand(
          c.prepare(operation, dto, request: e.id),
          r != null
              ? s.workSaveOnsite
              : p != null
              ? s.workProgress
              : s.workSaveTask,
          lines,
        );
      }
    }

    final links = {
      for (final value in c.requirementOptions?.items ?? <OnsiteView>[])
        value.id: value,
    };
    if (c.linkedRequirement != null) {
      links[c.linkedRequirement!.id] = c.linkedRequirement!;
    }
    return Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            r != null
                ? s.workSaveOnsite
                : p != null
                ? s.workProgress
                : s.workSaveTask,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (r != null) ...[
            Text(s.workOnsiteIntro),
            text(
              'work-reason',
              s.workReason,
              r.reason,
              (v) => e.onsite = e.onsite!.copyWith(reason: v),
              max: 1000,
              required: true,
              lines: 3,
            ),
            text(
              'work-location',
              s.workLocation,
              r.location,
              (v) => e.onsite = e.onsite!.copyWith(location: v),
              max: 200,
              required: true,
            ),
            text(
              'work-reference',
              s.workReference,
              r.reference,
              (v) => e.onsite = e.onsite!.copyWith(reference: v),
              max: 200,
            ),
            OutlinedButton(
              key: const Key('work-from'),
              onPressed: enabled ? () => date(true) : null,
              child: Text('${s.workFrom}: ${dayLabel(r.from)}'),
            ),
            OutlinedButton(
              key: const Key('work-to'),
              onPressed: enabled ? () => date(false) : null,
              child: Text('${s.workTo}: ${dayLabel(r.to)}'),
            ),
            Text(s.workInclusive),
            FilledButton.tonal(
              key: const Key('work-preview'),
              onPressed: enabled && !c.workLoading
                  ? () {
                      if (form.currentState!.validate()) c.previewWork();
                    }
                  : null,
              child: Text(s.workPreview),
            ),
            if (c.editorPreview != null)
              WorkConflicts(preview: c.editorPreview!, manager: c.manager),
          ],
          if (t != null) ...[
            text(
              'work-title',
              s.workTaskTitle,
              t.title,
              (v) => e.task = e.task!.copyWith(title: v),
              max: 200,
              required: true,
            ),
            text(
              'work-description',
              s.workDescription,
              t.description,
              (v) => e.task = e.task!.copyWith(description: v),
              lines: 3,
            ),
            OutlinedButton(
              key: const Key('work-deadline'),
              onPressed: enabled ? () => date(true) : null,
              child: Text('${s.workDeadline}: ${dayLabel(t.deadline)}'),
            ),
            DropdownButtonFormField<AssignedTaskState>(
              key: const Key('work-task-state'),
              initialValue: t.state,
              isExpanded: true,
              decoration: InputDecoration(labelText: s.workStatus),
              items: AssignedTaskState.values
                  .map(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Text(taskLabel(s, v)),
                    ),
                  )
                  .toList(),
              onChanged: enabled
                  ? (v) {
                      e.task = e.task!.copyWith(state: v!);
                      c.workInputChanged();
                    }
                  : null,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(s.workRequiresOnsite),
              subtitle: Text(s.workRequiresHint),
              value: t.requiresOnsite,
              onChanged: enabled
                  ? (v) {
                      e.task = e.task!.copyWith(requiresOnsite: v!);
                      c.workInputChanged();
                    }
                  : null,
            ),
            DropdownButtonFormField<String>(
              key: ValueKey(
                'work-link-${t.requirementId}-${links.keys.join()}',
              ),
              initialValue: t.requirementId ?? '',
              isExpanded: true,
              decoration: InputDecoration(labelText: s.workLinked),
              items: [
                DropdownMenuItem(value: '', child: Text(s.workNoLink)),
                for (final r in links.values.where(
                  (r) =>
                      r.state != OnsiteState.cancelled ||
                      r.id == t.requirementId,
                ))
                  DropdownMenuItem(
                    value: r.id,
                    child: Text(
                      '${r.reason} · ${onsiteLabel(s, r.state)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (t.requirementId != null &&
                    !links.containsKey(t.requirementId))
                  DropdownMenuItem(
                    value: t.requirementId,
                    child: Text(s.workLinked),
                  ),
              ],
              onChanged: enabled
                  ? (v) {
                      e.task = e.task!.copyWith(
                        requirementId: v == '' ? null : v,
                        requirementIdSetToNull: v == '',
                      );
                      c.workInputChanged();
                    }
                  : null,
            ),
            if (c.requirementOptions?.nextOffset != null)
              TextButton(
                onPressed: () => c.loadRequirementOptions(
                  offset: c.requirementOptions!.nextOffset!,
                ),
                child: Text(s.workMoreLinks),
              ),
            Text(s.workLinkHint),
          ],
          if (p != null) ...[
            DropdownButtonFormField<AssignedTaskState>(
              key: const Key('work-progress-state'),
              initialValue: p.state,
              isExpanded: true,
              decoration: InputDecoration(labelText: s.workStatus),
              items:
                  [
                        AssignedTaskState.todo,
                        AssignedTaskState.inProgress,
                        AssignedTaskState.done,
                      ]
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(taskLabel(s, v)),
                        ),
                      )
                      .toList(),
              onChanged: enabled
                  ? (v) {
                      e.progress = e.progress!.copyWith(state: v!);
                      c.workInputChanged();
                    }
                  : null,
            ),
            text(
              'work-progress-note',
              s.workProgressNote,
              p.note,
              (v) => e.progress = e.progress!.copyWith(note: v),
              lines: 3,
            ),
          ],
          if (error != null) Text(error!, key: const Key('work-form-error')),
          FilledButton(
            key: const Key('work-save'),
            onPressed: c.workCanWrite ? save : null,
            child: Text(s.planReview),
          ),
          TextButton(
            onPressed: enabled ? () => c.closeWorkEditor() : null,
            child: Text(s.planBack),
          ),
        ],
      ),
    );
  }
}
