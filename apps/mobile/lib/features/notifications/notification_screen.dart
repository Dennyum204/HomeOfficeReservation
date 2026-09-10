import 'dart:async';

import 'package:flutter/material.dart';
import 'package:homeoffice_api/api.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import 'inbox_controller.dart';
import 'push_coordinator.dart';

String notificationTitle(AppLocalizations s, String event) => switch (event) {
  'planning.submitted' => s.notificationSubmitted,
  'planning.withdrawn' => s.notificationWithdrawn,
  'planning.decided' => s.notificationDecided,
  'planning.counterproposed' => s.notificationProposed,
  'planning.counterproposal-accepted' => s.notificationAccepted,
  'onsite.created' => s.notificationOnsiteCreated,
  'onsite.edited' => s.notificationOnsiteEdited,
  'onsite.cancelled' => s.notificationOnsiteCancelled,
  'task.assigned' => s.notificationTaskAssigned,
  'task.updated' => s.notificationTaskUpdated,
  _ => s.notificationUnavailable,
};

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key, required this.controller, this.onOpen});
  final InboxController controller;
  final Future<void> Function(String)? onOpen;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final s = AppLocalizations.of(context)!;
      final c = controller;
      final detail = c.detail;
      Widget readButton(NotificationView item) => OutlinedButton(
        key: Key('read-${item.id}'),
        onPressed: c.busy ? null : () => c.read(item),
        child: Text(
          item.readAt == null
              ? s.notificationMarkRead
              : s.notificationMarkUnread,
        ),
      );
      Widget info(NotificationView item) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notificationTitle(s, item.eventType),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat.yMd('pt_PT').add_Hm().format(item.createdAt.toLocal()),
          ),
          Text(item.readAt == null ? s.notificationUnread : s.notificationRead),
          if (item.historical) Text(s.notificationArchiveHint),
        ],
      );
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            s.notificationsTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(s.notificationReadOnly),
          if (c.loading || c.busy) const LinearProgressIndicator(),
          if (c.error)
            Semantics(liveRegion: true, child: Text(s.notificationError)),
          if (c.unavailable) Text(s.notificationUnavailable),
          if (detail != null || c.unavailable) ...[
            TextButton(
              onPressed: c.closeDetail,
              child: Text(s.notificationBack),
            ),
            if (detail != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      info(detail),
                      const SizedBox(height: 16),
                      Text(
                        detail.destination == null
                            ? s.notificationUnavailable
                            : s.notificationReadOnly,
                      ),
                      if (detail.destination case final destination?) ...[
                        const SizedBox(height: 12),
                        Text(
                          s.notificationContext(switch (destination.kind) {
                            NotificationContext.request ||
                            NotificationContext.proposal => s.requests,
                            NotificationContext.requirement => s.onsite,
                            _ => s.tasks,
                          }),
                        ),
                      ],
                      const SizedBox(height: 12),
                      readButton(detail),
                      if (onOpen != null && detail.destination != null)
                        FilledButton(
                          onPressed: c.busy ? null : () => onOpen!(detail.id),
                          child: Text(s.notificationOpen),
                        ),
                    ],
                  ),
                ),
              ),
          ] else ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: c.filter,
              decoration: InputDecoration(labelText: s.notificationFilter),
              items: [
                DropdownMenuItem(value: 'all', child: Text(s.notificationAll)),
                DropdownMenuItem(
                  value: 'unread',
                  child: Text(s.notificationUnread),
                ),
                DropdownMenuItem(
                  value: 'archive',
                  child: Text(s.notificationArchive),
                ),
              ],
              onChanged: c.loading ? null : (value) => c.selectFilter(value!),
            ),
            Text(
              c.filter == 'archive'
                  ? s.notificationArchiveHint
                  : s.notificationAutomatic,
            ),
            TextButton.icon(
              onPressed: c.loading ? null : c.refresh,
              icon: const Icon(Icons.refresh),
              label: Text(s.notificationRefresh),
            ),
            if (!c.loading && c.page?.items.isEmpty == true)
              Text(s.notificationEmpty),
            for (final item in c.page?.items ?? <NotificationView>[])
              Card(
                key: Key('notification-${item.id}'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      info(item),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton.tonal(
                            onPressed: c.busy
                                ? null
                                : () => onOpen != null
                                      ? onOpen!(item.id)
                                      : c.open(item.id),
                            child: Text(s.notificationOpen),
                          ),
                          readButton(item),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            Wrap(
              spacing: 16,
              children: [
                TextButton(
                  onPressed: c.offset == 0 || c.loading
                      ? null
                      : () => c.next(c.offset - 20),
                  child: Text(s.notificationPrevious),
                ),
                TextButton(
                  onPressed: c.page?.nextOffset == null || c.loading
                      ? null
                      : () => c.next(c.page!.nextOffset!),
                  child: Text(s.notificationNext),
                ),
              ],
            ),
          ],
        ],
      );
    },
  );
}

class PushSettings extends StatelessWidget {
  const PushSettings({super.key, required this.controller});
  final PushCoordinator controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final s = AppLocalizations.of(context)!;
      final c = controller;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.pushTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(s.pushExplanation),
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(switch (c.status) {
                  PushStatus.unavailable => s.pushUnavailable,
                  PushStatus.enabled => s.pushEnabled,
                  PushStatus.denied => s.pushDenied,
                  PushStatus.error => s.pushError,
                  PushStatus.busy => s.authWait,
                  _ => s.pushOff,
                }),
              ),
              if (c.status == PushStatus.error && c.enabled)
                TextButton(
                  onPressed: () => unawaited(c.synchronize()),
                  child: Text(s.retry),
                ),
              if (c.status != PushStatus.unavailable)
                TextButton(
                  onPressed: c.status == PushStatus.busy
                      ? null
                      : () {
                          unawaited(
                            (c.enabled ? c.disable() : c.enable()).catchError(
                              (Object _) {},
                            ),
                          );
                        },
                  child: Text(c.enabled ? s.pushDisable : s.pushEnable),
                ),
            ],
          ),
        ),
      );
    },
  );
}
