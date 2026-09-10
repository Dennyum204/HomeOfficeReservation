import 'package:flutter/material.dart';
import 'package:homeoffice_api/api.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import 'planning_controller.dart';
import 'planning_dates.dart';
import 'planning_widgets.dart';

class PlanningCalendar extends StatelessWidget {
  const PlanningCalendar(
    this.controller, {
    super.key,
    required this.openRequest,
    required this.newRequest,
    this.openRequirement,
    this.newRequirement,
  });
  final PlanningController controller;
  final Future<void> Function(String) openRequest;
  final VoidCallback newRequest;
  final Future<void> Function(String)? openRequirement;
  final VoidCallback? newRequirement;
  @override
  Widget build(BuildContext context) {
    final c = controller, s = AppLocalizations.of(context)!;
    final grid = monthGrid(c.month);
    final selected = c.calendar?.effectiveDays
        .where((d) => sameDay(d.localDate, c.selectedDate))
        .firstOrNull;
    final pending =
        c.calendar?.pendingDays
            .where((d) => sameDay(d.day.localDate, c.selectedDate))
            .toList() ??
        [];
    final requirements =
        c.calendar?.requirements
            .where(
              (r) =>
                  !dayOnly(r.from).isAfter(c.selectedDate) &&
                  !dayOnly(r.to).isBefore(c.selectedDate),
            )
            .toList() ??
        [];
    final today = planningToday(
      c.calendar?.planningTimeZone ?? 'Europe/Zurich',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              tooltip: s.planPreviousMonth,
              key: const Key('calendar-previous'),
              onPressed: c.loading
                  ? null
                  : () => c.goMonth(DateTime(c.month.year, c.month.month - 1)),
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              DateFormat.yMMMM('pt_PT').format(c.month),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              tooltip: s.planNextMonth,
              key: const Key('calendar-next'),
              onPressed: c.loading
                  ? null
                  : () => c.goMonth(DateTime(c.month.year, c.month.month + 1)),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: c.loading ? null : c.today,
              child: Text(s.planToday),
            ),
            TextButton.icon(
              onPressed: c.loading ? null : c.refresh,
              icon: const Icon(Icons.refresh),
              label: Text(s.refresh),
            ),
          ],
        ),
        Row(
          children: List.generate(
            7,
            (i) => Expanded(
              child: Center(
                child: Text(
                  DateFormat.E('pt_PT')
                      .format(DateTime(2026, 9, 7 + i))
                      .substring(0, 3),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 3,
            childAspectRatio:
                (constraints.maxWidth / 7) /
                (MediaQuery.textScalerOf(context).scale(18) + 48),
            children: grid.map((date) {
              final day = c.calendar?.effectiveDays
                  .where((d) => sameDay(d.localDate, date))
                  .firstOrNull;
              final waiting =
                  c.calendar?.pendingDays
                      .where((d) => sameDay(d.day.localDate, date))
                      .length ??
                  0;
              final onsite =
                  c.calendar?.requirements
                      .where(
                        (r) =>
                            !dayOnly(r.from).isAfter(date) &&
                            !dayOnly(r.to).isBefore(date) &&
                            r.state != OnsiteState.cancelled,
                      )
                      .toList() ??
                  [];
              final conflict = onsite.any(
                (r) => r.state == OnsiteState.needsResolution,
              );
              final chosen = sameDay(date, c.selectedDate);
              final color = day == null
                  ? Colors.grey
                  : locationColor(day.location, day.availability);
              final label = [
                dayLabel(date),
                if (day != null)
                  locationLabel(s, day.location, day.availability),
                if (day?.origin == 'WeeklyPattern') s.planPattern,
                if (day?.origin == 'ApprovedRequest') s.planConfirmed,
                if (waiting > 0) '$waiting ${s.planPending}',
                if (conflict) s.planConflict,
                if (onsite.isNotEmpty && !conflict) s.planRequirement,
              ].join('. ');
              return Semantics(
                label: label,
                selected: chosen,
                button: true,
                excludeSemantics: true,
                child: Material(
                  color: chosen
                      ? const Color(0xffdcebdd)
                      : date.month == c.month.month
                      ? Colors.white
                      : const Color(0xffedf0ed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                    side: BorderSide(
                      color: chosen
                          ? const Color(0xff264e3e)
                          : const Color(0xffdce2db),
                      width: chosen ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    key: Key('calendar-${dateKey(date)}'),
                    onTap: () => c.selectDate(date),
                    borderRadius: BorderRadius.circular(9),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${date.day}',
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: sameDay(date, today) || chosen
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 1,
                            children: [
                              if (day != null)
                                Icon(
                                  locationIcon(day.location, day.availability),
                                  size: 14,
                                  color: color,
                                ),
                              if (day?.origin == 'WeeklyPattern')
                                Icon(Icons.repeat, size: 12, color: color),
                              if (waiting > 0)
                                const Icon(
                                  Icons.schedule,
                                  size: 14,
                                  color: Color(0xff8b5700),
                                ),
                              if (onsite.isNotEmpty)
                                Icon(
                                  conflict
                                      ? Icons.warning_amber
                                      : Icons.push_pin_outlined,
                                  size: 14,
                                  color: const Color(0xff653d83),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        ExpansionTile(
          title: Text(s.planLegend),
          tilePadding: EdgeInsets.zero,
          children: [
            PlanLabel(s.planPattern, Icons.repeat),
            PlanLabel(
              s.planRemote,
              Icons.home_outlined,
              color: const Color(0xff246142),
            ),
            PlanLabel(
              s.planOnsite,
              Icons.business_outlined,
              color: const Color(0xff20548a),
            ),
            PlanLabel(
              s.planPending,
              Icons.schedule,
              color: const Color(0xff8b5700),
            ),
            PlanLabel(s.planLeave, Icons.beach_access_outlined),
            PlanLabel(s.planUnavailable, Icons.do_not_disturb_alt_outlined),
            PlanLabel(s.planRequirement, Icons.push_pin_outlined),
            PlanLabel(s.planConflict, Icons.warning_amber),
          ],
        ),
        Text(s.planAgenda, style: Theme.of(context).textTheme.titleLarge),
        Text(dayLabel(c.selectedDate), key: const Key('agenda-date')),
        if (selected != null)
          PlanCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlanLabel(
                  locationLabel(s, selected.location, selected.availability),
                  locationIcon(selected.location, selected.availability),
                  color: locationColor(
                    selected.location,
                    selected.availability,
                  ),
                ),
                Text(
                  selected.origin == 'WeeklyPattern'
                      ? s.planPattern
                      : selected.origin == 'OnsiteRequirement'
                      ? s.planRequirement
                      : s.planConfirmed,
                ),
                if (selected.sourceRequestId != null)
                  TextButton(
                    onPressed: () => openRequest(selected.sourceRequestId!),
                    child: Text(s.planOpenRequest),
                  ),
              ],
            ),
          ),
        for (final day in pending)
          PlanCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlanLabel(s.planPending, Icons.schedule),
                Text(
                  day.day.cancel
                      ? s.planCancelled
                      : locationLabel(
                          s,
                          day.day.location,
                          day.day.availability,
                        ),
                ),
                if (day.day.baseDayId != null) Text(s.planRevisionHint),
                TextButton(
                  onPressed: () => openRequest(day.requestId),
                  child: Text(s.planOpenRequest),
                ),
              ],
            ),
          ),
        for (final requirement in requirements)
          PlanCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlanLabel(
                  requirement.state == OnsiteState.needsResolution
                      ? s.planConflict
                      : s.planRequirement,
                  Icons.push_pin_outlined,
                  color: const Color(0xff653d83),
                ),
                Text(requirement.reason),
                Text(requirement.location),
                if (requirement.state == OnsiteState.needsResolution)
                  Text(s.workConflict),
                TextButton(
                  onPressed: openRequirement == null
                      ? null
                      : () => openRequirement!(requirement.id),
                  child: Text(s.workOpen),
                ),
              ],
            ),
          ),
        if (pending.isEmpty && requirements.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(s.planNothing),
          ),
        if (c.own)
          FilledButton.icon(
            key: const Key('planning-new-request'),
            onPressed: c.canWrite ? newRequest : null,
            icon: const Icon(Icons.add),
            label: Text(c.hasSavedEditor ? s.planRestoreDraft : s.planNew),
          ),
        if (c.manager && newRequirement != null)
          FilledButton.tonal(
            key: const Key('calendar-new-onsite'),
            onPressed: c.canWrite ? newRequirement : null,
            child: Text(s.workNewOnsite),
          ),
        if (c.updatedAt != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              '${s.planUpdated}: ${DateFormat.Hm('pt_PT').format(c.updatedAt!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
