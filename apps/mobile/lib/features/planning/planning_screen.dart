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
    this.onRequirement,
    this.onNewRequirement,
  });
  final PlanningController controller;
  final bool requests;
  final VoidCallback onRequests;
  final Future<void> Function(String)? onRequirement;
  final VoidCallback? onNewRequirement;
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
            PlanningEmployeePicker(c),
            const SizedBox(height: 12),
            PlanningNotice(c),
            if (c.initialized && c.employees.isEmpty) Text(s.planNoEmployees),
            if (review != null)
              PlanningConfirmation(c)
            else if (c.editor != null)
              PlanningEditorView(c, key: ObjectKey(c.editor))
            else if (requests && c.detail != null)
              PlanningRequestDetail(c, key: ValueKey(c.detail!.id))
            else if (c.employeeId != null)
              requests
                  ? PlanningRequests(c)
                  : PlanningCalendar(
                      c,
                      openRequirement: onRequirement,
                      newRequirement: onNewRequirement,
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
