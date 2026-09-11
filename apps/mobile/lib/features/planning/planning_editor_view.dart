import 'package:flutter/material.dart';
import 'package:homeoffice_api/api.dart';

import '../../l10n/generated/app_localizations.dart';
import 'planning_controller.dart';
import 'planning_dates.dart';
import 'planning_editor.dart';
import 'planning_repository.dart';
import 'planning_widgets.dart';
import '../../theme/components.dart';

class PlanningEditorView extends StatefulWidget {
  const PlanningEditorView(this.controller, {super.key});
  final PlanningController controller;
  @override
  State<PlanningEditorView> createState() => _PlanningEditorViewState();
}

class _PlanningEditorViewState extends State<PlanningEditorView> {
  WorkLocation location = WorkLocation.remotePortugal;
  Availability availability = Availability.working;
  bool weekends = false, previewing = false;
  DateTimeRange? range;
  List<DateTime>? preview;
  String? error;
  int previewGeneration = 0;
  PlanningController get c => widget.controller;
  DateTime get today =>
      planningToday(c.calendar?.planningTimeZone ?? 'Europe/Zurich');
  void addDates(List<DateTime> values) {
    final e = c.editor!;
    final dates = {for (final day in e.days) dateKey(day.localDate): day};
    for (final date in values) {
      dates.putIfAbsent(
        dateKey(date),
        () => DayInput(
          localDate: dayOnly(date),
          availability: availability,
          location: availability == Availability.working
              ? location
              : WorkLocation.unplanned,
        ),
      );
    }
    e.days = dates.values.toList()
      ..sort((a, b) => dateKey(a.localDate).compareTo(dateKey(b.localDate)));
    setState(() {
      preview = null;
      error = null;
    });
    c.inputChanged();
  }

  Future<void> single() async {
    final employee = c.employeeId;
    final date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: shiftDay(today, 730),
      helpText: AppLocalizations.of(context)!.planSingle,
    );
    if (mounted && c.active && employee == c.employeeId && date != null) {
      addDates([date]);
    }
  }

  Future<void> chooseRange() async {
    final employee = c.employeeId;
    final value = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: shiftDay(today, 730),
      initialDateRange: range,
      helpText: AppLocalizations.of(context)!.planRange,
    );
    if (mounted && c.active && employee == c.employeeId && value != null) {
      setState(() {
        range = value;
        preview = null;
        previewGeneration++;
      });
    }
  }

  Future<void> previewRange() async {
    if (range == null || previewing) return;
    final generation = ++previewGeneration;
    setState(() {
      previewing = true;
      preview = null;
    });
    final result = await c.preview(range!.start, range!.end, weekends);
    if (mounted && generation == previewGeneration) {
      setState(() {
        preview = result;
        previewing = false;
      });
    }
  }

  void updateDay(int index, DayInput day) {
    final days = c.editor!.days.toList();
    days[index] = day;
    c.editor!.days = days;
    c.inputChanged();
  }

  void save() {
    final e = c.editor!, s = AppLocalizations.of(context)!;
    if (e.days.isEmpty) {
      setState(() => error = s.planEmptyDates);
      return;
    }
    if (e.mode == EditorMode.proposal && e.note.trim().isEmpty) {
      setState(() => error = s.planReasonRequired);
      return;
    }
    final source = c.detail;
    if (e.requestId != null && source?.id != e.requestId) return;
    final proposal = e.mode == EditorMode.proposal;
    final operation = proposal
        ? e.proposalId == null
              ? PlanningOperation.propose
              : PlanningOperation.reviseProposal
        : e.mode == EditorMode.edit
        ? PlanningOperation.editDraft
        : PlanningOperation.createDraft;
    final Object dto = proposal
        ? ProposalInput(
            expectedCalendarVersion: c.calendar!.calendarVersion,
            expectedRequestVersion: source!.version,
            affectedDays: e.affected,
            days: e.days,
            reason: e.note,
            requirementId: e.requirementId,
            requirementRevision: e.requirementRevision,
          )
        : DraftInput(
            expectedCalendarVersion: c.calendar!.calendarVersion,
            expectedRequestVersion: e.mode == EditorMode.edit
                ? source!.version
                : null,
            parentRevisionId: e.mode == EditorMode.revision
                ? e.requestId
                : e.parentRevisionId,
            note: e.note,
            days: e.days,
          );
    final command = c.prepare(
      operation,
      dto,
      request: e.requestId,
      proposal: e.proposalId,
    );
    c.reviewCommand(command, proposal ? s.planPropose : s.planSaveDraft, [
      for (final day in e.days)
        '${dayLabel(day.localDate)} · ${day.cancel ? s.planCancelled : locationLabel(s, day.location, day.availability)}',
      if (e.note.isNotEmpty) e.note,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!, e = c.editor!;
    final disabled = c.locked || previewing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          e.mode == EditorMode.proposal
              ? s.planPropose
              : e.mode == EditorMode.revision
              ? s.planChange
              : e.mode == EditorMode.edit
              ? s.planEditDraft
              : s.planNew,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (e.mode == EditorMode.revision || e.parentRevisionId != null)
          Text(s.planRevisionHint),
        if (e.mode == EditorMode.proposal) ...[
          Text(s.planProposalHint),
          Text(s.planAffected),
          for (final day
              in c.detail?.days.where(
                    (d) => e.affected.any((a) => a.dayId == d.id),
                  ) ??
                  <RequestedDayView>[])
            Text(
              '${dayLabel(day.localDate)} · ${decisionLabel(s, day.decision)}',
            ),
        ],
        const SizedBox(height: 12),
        FormSection(
          title: s.visualContext,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<Availability>(
                initialValue: availability,
                isExpanded: true,
                decoration: InputDecoration(labelText: s.planAvailabilityLabel),
                items: Availability.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          value == Availability.working
                              ? s.planWorking
                              : value == Availability.leave
                              ? s.planLeave
                              : s.planUnavailable,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: disabled
                    ? null
                    : (value) => setState(() => availability = value!),
              ),
              if (availability != Availability.working) Text(s.planManualHint),
              const SizedBox(height: 12),
              DropdownButtonFormField<WorkLocation>(
                initialValue: location,
                isExpanded: true,
                decoration: InputDecoration(labelText: s.planLocation),
                items:
                    [
                          WorkLocation.remotePortugal,
                          WorkLocation.officeSwitzerland,
                        ]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(
                              locationLabel(s, value, Availability.working),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: disabled || availability != Availability.working
                    ? null
                    : (value) => setState(() => location = value!),
              ),
            ],
          ),
        ),
        FormSection(
          title: s.visualDates,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const Key('editor-single'),
                    onPressed: disabled ? null : single,
                    icon: const Icon(Icons.add),
                    label: Text(s.planSingle),
                  ),
                  OutlinedButton.icon(
                    key: const Key('editor-range'),
                    onPressed: disabled ? null : chooseRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(s.planRange),
                  ),
                ],
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: weekends,
                title: Text(s.planWeekends),
                onChanged: disabled
                    ? null
                    : (value) => setState(() {
                        weekends = value!;
                        preview = null;
                        previewGeneration++;
                      }),
              ),
              if (range != null) ...[
                Text('${dayLabel(range!.start)} → ${dayLabel(range!.end)}'),
                TextButton(
                  key: const Key('editor-preview'),
                  onPressed: disabled ? null : previewRange,
                  child: Text(s.planPreview),
                ),
              ],
              if (previewing) const LinearProgressIndicator(),
              if (preview != null)
                PlanCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('${s.planIncluded}: ${preview!.length}'),
                      for (final date in preview!) Text(dayLabel(date)),
                      FilledButton.tonal(
                        key: const Key('editor-add-preview'),
                        onPressed: disabled || preview!.isEmpty
                            ? null
                            : () => addDates(preview!),
                        child: Text(s.planAddPreview),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        FormSection(
          title: s.visualSummary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${s.planIncluded}: ${e.days.length}',
                key: const Key('editor-day-count'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (var i = 0; i < e.days.length; i++)
                PlanCard(
                  key: ValueKey(dateKey(e.days[i].localDate)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(dayLabel(e.days[i].localDate))),
                          IconButton(
                            tooltip: s.planRemoveDate,
                            key: Key('remove-${dateKey(e.days[i].localDate)}'),
                            onPressed: disabled
                                ? null
                                : () {
                                    e.days = e.days.toList()..removeAt(i);
                                    c.inputChanged();
                                  },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      DropdownButtonFormField<Availability>(
                        key: ValueKey(
                          '${dateKey(e.days[i].localDate)}-${e.days[i].availability}-${e.days[i].cancel}',
                        ),
                        initialValue: e.days[i].availability,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: s.planAvailabilityLabel,
                        ),
                        items: Availability.values
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(
                                  value == Availability.working
                                      ? s.planWorking
                                      : value == Availability.leave
                                      ? s.planLeave
                                      : s.planUnavailable,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: disabled || e.days[i].cancel
                            ? null
                            : (value) => updateDay(
                                i,
                                e.days[i].copyWith(
                                  availability: value,
                                  location: value == Availability.working
                                      ? WorkLocation.remotePortugal
                                      : WorkLocation.unplanned,
                                ),
                              ),
                      ),
                      if (e.days[i].availability == Availability.working &&
                          !e.days[i].cancel)
                        DropdownButtonFormField<WorkLocation>(
                          key: ValueKey(
                            '${dateKey(e.days[i].localDate)}-${e.days[i].location}',
                          ),
                          initialValue:
                              e.days[i].location == WorkLocation.unplanned
                              ? WorkLocation.remotePortugal
                              : e.days[i].location,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: s.planLocation,
                          ),
                          items:
                              [
                                    WorkLocation.remotePortugal,
                                    WorkLocation.officeSwitzerland,
                                  ]
                                  .map(
                                    (value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(
                                        locationLabel(
                                          s,
                                          value,
                                          Availability.working,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: disabled
                              ? null
                              : (value) => updateDay(
                                  i,
                                  e.days[i].copyWith(location: value),
                                ),
                        ),
                      if (e.days[i].baseDayId != null)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: e.days[i].cancel,
                          title: Text(s.planCancelled),
                          onChanged: disabled
                              ? null
                              : (value) => updateDay(
                                  i,
                                  e.days[i].copyWith(
                                    cancel: value,
                                    location: value!
                                        ? WorkLocation.unplanned
                                        : WorkLocation.remotePortugal,
                                    availability: Availability.working,
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        FormSection(
          title: s.visualComment,
          child: TextFormField(
            key: const Key('editor-note'),
            maxLength: e.mode == EditorMode.proposal ? 1000 : 2000,
            initialValue: e.note,
            minLines: 2,
            maxLines: 6,
            enabled: !disabled,
            decoration: InputDecoration(
              labelText: e.mode == EditorMode.proposal
                  ? s.planReason
                  : s.planNote,
            ),
            onChanged: (value) {
              e.note = value;
              c.inputChanged();
            },
          ),
        ),
        if (error != null) Semantics(liveRegion: true, child: Text(error!)),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('editor-save'),
          onPressed:
              c.canWrite && (e.requestId == null || c.detail?.id == e.requestId)
              ? save
              : null,
          child: Text(
            e.mode == EditorMode.proposal ? s.planPropose : s.planSaveDraft,
          ),
        ),
        TextButton(
          onPressed: c.locked ? null : () => c.closeEditor(),
          child: Text(s.planCloseEditor),
        ),
        TextButton(
          onPressed: c.locked ? null : () => c.closeEditor(discard: true),
          child: Text(s.planDiscard),
        ),
      ],
    );
  }
}
