import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'planning_controller.dart';
import 'planning_calendar.dart';
import 'planning_editor_view.dart';
import 'planning_requests.dart';
import 'planning_widgets.dart';

class PlanningScreen extends StatelessWidget {
  const PlanningScreen({
    super.key,
    required this.controller,
    required this.requests,
    required this.onRequests,
  });
  final PlanningController controller;
  final bool requests;
  final VoidCallback onRequests;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final c = controller, s = AppLocalizations.of(context)!;
      final review = c.review;
      final internal =
          review != null || c.editor != null || requests && c.detail != null;
      void back() {
        if (review != null) {
          c.closeReview();
        } else if (c.editor != null) {
          c.closeEditor();
        } else {
          c.closeDetail();
        }
      }

      return PopScope(
        canPop: !internal,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && !c.busy) back();
        },
        child: ListView(
          key: PageStorageKey(
            'planning-${c.employeeId}-$requests-${review != null}-${c.editor != null}-${c.detail?.id}',
          ),
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              c.manager ? s.planManagerTitle : s.planTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            if (c.employees.isNotEmpty)
              DropdownButtonFormField<String>(
                key: ValueKey('employee-${c.employeeId}'),
                initialValue: c.employeeId,
                isExpanded: true,
                decoration: InputDecoration(labelText: s.planEmployee),
                items: c.employees
                    .map(
                      (member) => DropdownMenuItem(
                        value: member.memberId,
                        child: Text(member.displayName),
                      ),
                    )
                    .toList(),
                onChanged: c.locked || c.editor != null || review != null
                    ? null
                    : (value) => c.selectEmployee(value!),
              ),
            const SizedBox(height: 12),
            PlanningNotice(c),
            if (c.initialized && c.employees.isEmpty) Text(s.planNoEmployees),
            if (review != null) ...[
              Text(
                s.planReview,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(review.title, style: Theme.of(context).textTheme.titleLarge),
              Text(s.planSendingHint),
              for (final line in review.lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(line),
                ),
              FilledButton(
                key: const Key('planning-confirm'),
                onPressed: c.canWrite ? c.confirmReview : null,
                child: Text(s.planConfirm),
              ),
              TextButton(
                onPressed: c.busy ? null : c.closeReview,
                child: Text(s.planBack),
              ),
            ] else if (c.editor != null)
              PlanningEditorView(c, key: ObjectKey(c.editor))
            else if (requests && c.detail != null)
              PlanningRequestDetail(c, key: ValueKey(c.detail!.id))
            else if (c.employeeId != null)
              requests
                  ? PlanningRequests(c)
                  : PlanningCalendar(
                      c,
                      openRequest: (id) async {
                        onRequests();
                        await c.openRequest(id);
                      },
                      newRequest: () {
                        onRequests();
                        c.newEditor();
                      },
                    ),
          ],
        ),
      );
    },
  );
}
